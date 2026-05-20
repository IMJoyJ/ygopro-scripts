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
-- 效果①的发动准备与合法性检测
function c55838342.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将该卡作为指定属性、种族、攻守、等级的效果怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,55838342,0,TYPES_EFFECT_TRAP_MONSTER,300,2100,2,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身作为效果怪兽特殊召唤
function c55838342.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否能将该卡作为怪兽特殊召唤，不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,55838342,0,TYPES_EFFECT_TRAP_MONSTER,300,2100,2,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将自身以自身效果特殊召唤到怪兽区域
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 效果②的发动条件判定：必须是由自身效果特殊召唤，且特殊召唤到连接怪兽所连接的区域
function c55838342.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSummonType()~=SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF then return false end
	-- 获取自己场上所有连接怪兽所连接的怪兽区域的卡片组
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方场上所有连接怪兽所连接的怪兽区域的卡片组
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	return (lg1 and lg1:IsContains(c)) or (lg2 and lg2:IsContains(c))
end
-- 过滤卡组中「星遗物」卡片的条件（字段为0xfe且能加入手牌）
function c55838342.filter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的「星遗物」卡，并设置操作信息
function c55838342.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「星遗物」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55838342.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1张「星遗物」卡加入手牌并给对方确认
function c55838342.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「星遗物」卡
	local g=Duel.SelectMatchingCard(tp,c55838342.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
