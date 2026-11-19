--クローラー・パラディオン
-- 效果：
-- ①：这张卡发动后变成效果怪兽（昆虫族·地·2星·攻300/守2100）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果让这张卡往连接怪兽所连接区的特殊召唤成功的场合才能发动。从卡组把1张「星遗物」卡加入手卡。
function c55838342.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（昆虫族·地·2星·攻300/守2100）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c55838342.target)
	e1:SetOperation(c55838342.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡往连接怪兽所连接区的特殊召唤成功的场合才能发动。从卡组把1张「星遗物」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55838342,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c55838342.thcon)
	e2:SetTarget(c55838342.thtg)
	e2:SetOperation(c55838342.thop)
	c:RegisterEffect(e2)
end
-- ①效果发动检查函数：确认已完成Cost检查、自己怪兽区有空位，且满足特殊召唤该陷阱效果怪兽（昆虫族·地·2星·攻300/守2100）的条件。
function c55838342.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区是否有至少1个可用空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤符合设定参数（昆虫族·地·2星·攻300/守2100·效果陷阱怪兽）的怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,55838342,0,TYPES_EFFECT_TRAP_MONSTER,300,2100,2,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 向引擎登记本次连锁确定将这张卡自身特殊召唤（1张）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理函数：再次验证能否特殊召唤该参数怪兽后，为这张卡赋予效果怪兽与陷阱属性并将其以表侧表示特殊召唤到自己怪兽区。
function c55838342.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家当前是否仍能特殊召唤该设定的陷阱效果怪兽，若不能则中止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,55838342,0,TYPES_EFFECT_TRAP_MONSTER,300,2100,2,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果召唤方式(SUMMON_VALUE_SELF)将这张卡无视召唤条件以表侧表示特殊召唤到自己怪兽区域。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- ②效果发动条件函数：确认这张卡是通过自身效果特殊召唤成功，且当前位于己方或对方连接怪兽的连接端（所连接区）。
function c55838342.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSummonType()~=SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF then return false end
	-- 获取以自己视角来看所有处于连接状态的卡片组。
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取以对方视角来看所有处于连接状态的卡片组。
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	return (lg1 and lg1:IsContains(c)) or (lg2 and lg2:IsContains(c))
end
-- 定义检索过滤函数，检查卡片是否属于「星遗物」(0xfe)字段且可以加入手卡。
function c55838342.filter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- ②效果发动检查函数：确认这张卡目前仍在怪兽区域且卡组中存在至少1张可检索的「星遗物」卡。
function c55838342.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_MZONE)
		-- 检查自己卡组中是否存在至少1张满足条件的「星遗物」卡。
		and Duel.IsExistingMatchingCard(c55838342.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向引擎登记本次连锁预计从自己卡组将1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理函数：让玩家从卡组选择1张「星遗物」卡加入手卡并向对方展示确认。
function c55838342.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要加入手卡的卡片提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「星遗物」卡。
	local g=Duel.SelectMatchingCard(tp,c55838342.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选中的「星遗物」卡加入发动玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
