--遺跡の魔鉱戦士
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上没有「勇者衍生物」存在的场合，这张卡不能攻击。
-- ③：有「勇者衍生物」的衍生物名记述的自己怪兽进行战斗的战斗阶段结束时才能发动。从卡组选有「勇者衍生物」的衍生物名记述的1张陷阱卡在自己的魔法与陷阱区域盖放。
function c66078354.initial_effect(c)
	-- 注册「勇者衍生物」（卡号3285552）到该卡的关联卡片密码列表中。
	aux.AddCodeList(c,3285552)
	-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,66078354)
	e1:SetCondition(c66078354.spcon)
	e1:SetTarget(c66078354.sptg)
	e1:SetOperation(c66078354.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上没有「勇者衍生物」存在的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c66078354.atkcon)
	c:RegisterEffect(e2)
	-- ③：有「勇者衍生物」的衍生物名记述的自己怪兽进行战斗的战斗阶段结束时才能发动。从卡组选有「勇者衍生物」的衍生物名记述的1张陷阱卡在自己的魔法与陷阱区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,66078355)
	e3:SetCondition(c66078354.setcon)
	e3:SetTarget(c66078354.settg)
	e3:SetOperation(c66078354.setop)
	c:RegisterEffect(e3)
	if not c66078354.global_check then
		c66078354.global_check=true
		-- 有「勇者衍生物」的衍生物名记述的自己怪兽进行战斗
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c66078354.checkop)
		-- 注册全局环境下的事件监听效果，用于记录是否有符合条件的怪兽进行战斗。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查卡片是否在效果文本中记述了「勇者衍生物」的辅助函数。
function c66078354.check(c)
	-- 判断卡片是否存在且其效果文本中是否记述了「勇者衍生物」的卡名。
	return c and aux.IsCodeListed(c,3285552)
end
-- 伤害计算后触发的全局操作函数，用于检测并记录进行战斗的怪兽是否记述了「勇者衍生物」。
function c66078354.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中双方的怪兽。
	local a,d=Duel.GetBattleMonster(0)
	-- 如果玩家0（自己）的战斗怪兽记述了「勇者衍生物」，则为玩家0注册一个持续到回合结束的标识效果。
	if c66078354.check(a) then Duel.RegisterFlagEffect(0,66078354,RESET_PHASE+PHASE_END,0,1) end
	-- 如果玩家1（对方）的战斗怪兽记述了「勇者衍生物」，则为玩家1注册一个持续到回合结束的标识效果。
	if c66078354.check(d) then Duel.RegisterFlagEffect(1,66078354,RESET_PHASE+PHASE_END,0,1) end
end
-- 过滤场上表侧表示的「勇者衍生物」的条件函数。
function c66078354.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 效果①特殊召唤的条件函数。
function c66078354.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「勇者衍生物」。
	return Duel.IsExistingMatchingCard(c66078354.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①特殊召唤的发动准备（检查与效果分类设置）函数。
function c66078354.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①特殊召唤的处理函数。
function c66078354.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②不能攻击的条件函数。
function c66078354.atkcon(e)
	-- 检查自己场上是否不存在表侧表示的「勇者衍生物」。
	return not Duel.IsExistingMatchingCard(c66078354.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 效果③盖放陷阱卡的条件函数。
function c66078354.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否有记述了「勇者衍生物」的自己怪兽进行过战斗（即检查是否存在对应的标识效果）。
	return Duel.GetFlagEffect(tp,66078354)>0
end
-- 过滤卡组中记述了「勇者衍生物」且可以盖放的陷阱卡的条件函数。
function c66078354.setfilter(c)
	-- 判断卡片是否记述了「勇者衍生物」、是否为陷阱卡，以及是否可以盖放到场上。
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果③盖放陷阱卡的发动准备（检查）函数。
function c66078354.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c66078354.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果③盖放陷阱卡的处理函数。
function c66078354.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c66078354.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g)
	end
end
