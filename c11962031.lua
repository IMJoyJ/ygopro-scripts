--サラマングレイト・オブ・ファイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「炽焰转生炎兽小妖」外的1只4星以下的「转生炎兽」怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能特殊召唤。
-- ②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数：为这张卡注册两个效果——①的检索效果（e1/e2分别对应召唤/特殊召唤成功时触发）与②的墓地除外自身破坏己方电子界族怪兽的效果（e3）。
function s.initial_effect(c)
	-- 对应效果原文：“①：这张卡召唤·特殊召唤的场合才能发动。除「炽焰转生炎兽小妖」外的1只4星以下的「转生炎兽」怪兽从卡组加入手卡。”（此段实现通常召唤成功时的e1，特殊召唤成功时的触发由e2克隆实现）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对应效果原文：“②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	-- 设置②效果的发动代价：将墓地的这张卡除外（aux.bfgcost是通用的除外自身作为COST的函数）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 检索筛选函数：满足等级4以下、字段为「转生炎兽」（0x119）、是怪兽卡、不是本卡（id）且能够加入手卡的「转生炎兽」怪兽。
function s.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息设置：卡组存在符合条件的检索对象时可发动，并设置“将1张卡加入手卡”的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己卡组中至少存在1张满足s.thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理会执行从卡组将1张卡加入手卡的操作（CATEGORY_TOHAND），供其他卡连锁时检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1只符合条件的「转生炎兽」怪兽加入手卡并给对方确认，然后给自己附加‘直到回合结束不是炎属性怪兽不能特殊召唤’的自肃效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让当前玩家选择要加入手牌的卡（提示文本为“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从对方没有限制的位置（自己卡组）选择1张满足s.thfilter的卡加入手牌；此处min=max=1，所以必须选1张。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去（加入）其持有者的手卡（第二参数nil表示送回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 对应效果原文：“这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能特殊召唤。”以及“②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到玩家tp身上：该效果以玩家为对象，持续到结束阶段，限制其不能特殊召唤非炎属性怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：当要特殊召唤的怪兽不是炎属性时返回true，表示不能进行该特殊召唤。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ②效果的发动条件：在伤害步骤开始时，确定进行战斗的己方怪兽（若攻击者是对方则取攻击对象，否则取攻击者），且该怪兽表侧表示并属于电子界族。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前伤害步骤中进行攻击的怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方控制的，则改取被攻击的己方怪兽作为对象，以保证最终判定的是己方电子界族怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsRace(RACE_CYBERSE)
end
-- ②效果的目标确认与操作信息设置：取出条件中保存的己方电子界族怪兽，确认其仍可作为目标，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置操作信息：本连锁将破坏bc这1只怪兽（CATEGORY_DESTROY），供系统进行效果相关性检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- ②效果处理：若标签中保存的怪兽仍在战斗相关区域中且仍由自己控制，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(tp) then
		-- 以效果原因将bc破坏（送去墓地）。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
