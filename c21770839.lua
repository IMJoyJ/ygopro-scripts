--オッドアイズ・ファンタズマ・ドラゴン
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。从自己的额外卡组把1只表侧表示的龙族灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己的灵摆区域有2张卡存在，自己的额外卡组有表侧表示的「异色眼」灵摆怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不能灵摆召唤。
-- ②：这张卡向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己的额外卡组的表侧表示的灵摆怪兽数量×1000。
function c21770839.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性，使其支持灵摆召唤与灵摆卡在灵摆区域的发动。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：丢弃1张手卡才能发动。从自己的额外卡组把1只表侧表示的龙族灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21770839,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,21770839)
	e1:SetCost(c21770839.thcost)
	e1:SetTarget(c21770839.thtg)
	e1:SetOperation(c21770839.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：自己的灵摆区域有2张卡存在，自己的额外卡组有表侧表示的「异色眼」灵摆怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不能灵摆召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21770839,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,21770840)
	e2:SetCondition(c21770839.spcon)
	e2:SetCost(c21770839.spcost)
	e2:SetTarget(c21770839.sptg)
	e2:SetOperation(c21770839.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己的额外卡组的表侧表示的灵摆怪兽数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21770839,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCountLimit(1,21770841)
	e3:SetCondition(c21770839.atkcon)
	e3:SetOperation(c21770839.atkop)
	c:RegisterEffect(e3)
	-- 注册一个自定义活动计数器，用于记录本回合玩家进行过非灵摆特殊召唤的次数（上限1次），该计数作为怪兽效果①的发动条件之一，并配合后续“不能灵摆召唤”的自肃效果。
	Duel.AddCustomActivityCounter(21770839,ACTIVITY_SPSUMMON,c21770839.counterfilter)
end
-- 计数器过滤函数：只要特殊召唤方式不是灵摆召唤，本次特殊召唤就会被计入该计数器（即记录非灵摆特殊召唤次数）。
function c21770839.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果①的代价处理：选择并丢弃1张手卡作为发动COST；如果支付不了则不能发动。
function c21770839.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：手牌中是否存在至少1张可丢弃的卡，以判断能否支付丢弃1张手卡的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手卡选1张可丢弃的卡丢弃，原因标记为COST与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：额外卡组表侧表示的龙族灵摆怪兽，且可以加入手卡。
function c21770839.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果①的目标设定：确认额外卡组存在符合条件的表侧龙族灵摆怪兽后，设置把1张该类卡加入手卡的操作信息。
function c21770839.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：自己的额外卡组中是否存在至少1张符合条件的表侧龙族灵摆怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21770839.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：宣告本效果属于回手牌效果，预计从自己的额外卡组选1张卡加入手卡（目标在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果①结算：让玩家从额外卡组选择1张符合条件的龙族灵摆怪兽加入手卡，并向对方展示所选的卡。
function c21770839.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己额外卡组筛选并选择1张满足thfilter条件的表侧龙族灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c21770839.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那张灵摆怪兽以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡，使对方确认检索到的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义「异色眼」灵摆怪兽过滤器：表侧表示且属于「异色眼」系列、类型为灵摆怪兽。
function c21770839.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)
end
-- 怪兽效果①的发动条件：自己灵摆区域两个格子都有卡，且额外卡组有表侧「异色眼」灵摆怪兽，满足时才可发动。
function c21770839.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域的两个灵摆格是否都放有卡。
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		-- 同时检查额外卡组是否存在至少1张表侧表示且属于「异色眼」的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c21770839.exfilter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 怪兽效果①的代价与自肃：确认本回合没有进行过非灵摆特殊召唤后，发动时给自身附加“本回合不能灵摆召唤”的限制。
function c21770839.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：通过活动计数器确认本回合尚未进行过非灵摆特殊召唤（计数为0）。
	if chk==0 then return Duel.GetCustomActivityCount(21770839,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：自己的灵摆区域有2张卡存在，自己的额外卡组有表侧表示的「异色眼」灵摆怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果发动的回合，自己不能灵摆召唤。②：这张卡向对方怪兽攻击的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时下降自己的额外卡组的表侧表示的灵摆怪兽数量×1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c21770839.splimit)
	e1:SetTargetRange(1,0)
	-- 将刚创建好的“不能灵摆召唤”效果注册给当前玩家，使其在回合结束前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：若特殊召唤方式为灵摆召唤，则禁止该次特殊召唤。
function c21770839.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 特殊召唤的目标条件：我方怪兽区域有空位，且这张卡可以从手卡被特殊召唤。
function c21770839.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方怪兽区域是否存在可用空位，以决定能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将特殊召唤这张卡自身，分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的实际处理：若这张卡仍与发动效果相关联，则将其从手卡表侧表示特殊召唤。
function c21770839.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：以表侧表示形式将这张卡特殊召唤到我方场上，不检查召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击力变化用过滤器：统计表侧表示的灵摆怪兽，用于计算额外卡组中表侧灵摆怪兽数量。
function c21770839.atkfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
-- 攻击力下降效果的发动条件：这张卡作为攻击怪兽进行攻击，战斗对象为对方面表侧怪兽，且额外卡组有表侧灵摆怪兽，在伤害计算时满足可发动。
function c21770839.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=c:GetBattleTarget()
	-- 统计自己额外卡组中表侧表示灵摆怪兽的数量，作为下降攻击力的数值基准。
	local gc=Duel.GetMatchingGroupCount(c21770839.atkfilter,tp,LOCATION_EXTRA,0,nil)
	-- 条件综合判断：这张卡是攻击者、战斗对象是对方表侧怪兽且额外卡组存在表侧灵摆怪兽，全部满足才可发动。
	return c==Duel.GetAttacker() and d and d:IsFaceup() and not d:IsControler(tp) and gc>0
end
-- 效果结算：使对方战斗对象的攻击力下降（自己额外卡组表侧灵摆怪兽数量×1000），仅在那次伤害计算时适用。
function c21770839.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡的战斗对象（对方怪兽），作为攻击力下降效果的目标。
	local d=Duel.GetAttacker():GetBattleTarget()
	-- 再次统计自己额外卡组表侧灵摆怪兽数量，用于计算下降数值。
	local gc=Duel.GetMatchingGroupCount(c21770839.atkfilter,tp,LOCATION_EXTRA,0,nil)
	if d:IsRelateToBattle() and d:IsFaceup() then
		-- ②：那只对方怪兽的攻击力只在那次伤害计算时下降自己的额外卡组的表侧表示的灵摆怪兽数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(-gc*1000)
		d:RegisterEffect(e1)
	end
end
