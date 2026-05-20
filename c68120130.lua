--ジャンク・ディフェンダー
-- 效果：
-- 对方怪兽的直接攻击宣言时，这张卡可以从手卡特殊召唤。此外，1回合1次，可以把这张卡的守备力直到结束阶段时上升300。这个效果在对方回合也能发动。
function c68120130.initial_effect(c)
	-- 对方怪兽的直接攻击宣言时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68120130,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c68120130.spcon)
	e1:SetTarget(c68120130.sptg)
	e1:SetOperation(c68120130.spop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把这张卡的守备力直到结束阶段时上升300。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68120130,1))  --"守备上升"
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	-- 设置效果发动条件为不在伤害计算后（限制在伤害步骤中只能在伤害计算前发动）
	e2:SetCondition(aux.dscon)
	e2:SetOperation(c68120130.defup)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤效果的发动条件函数，判断是否为对方怪兽的直接攻击宣言
function c68120130.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 定义特殊召唤效果的靶向与检测函数，检查怪兽区域空格并向对方展示手卡
function c68120130.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动检测阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向对方玩家展示手卡中的这张卡以进行确认
	Duel.ConfirmCards(1-tp,c)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
	-- 设置连锁操作信息，表明该效果包含将这张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义特殊召唤效果的操作函数，将自身特殊召唤到场上
function c68120130.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义守备力上升效果的操作函数，为自身添加守备力上升的单体效果
function c68120130.defup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 可以把这张卡的守备力直到结束阶段时上升300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
