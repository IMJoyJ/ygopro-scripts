--チェックサム・ドラゴン
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，自己基本分回复这张卡的守备力一半的数值。
-- ②：攻击表示的这张卡不会被战斗破坏。
function c94136469.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，自己基本分回复这张卡的守备力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94136469,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94136469.spcon)
	e1:SetTarget(c94136469.sptg)
	e1:SetOperation(c94136469.spop)
	c:RegisterEffect(e1)
	-- ②：攻击表示的这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	e2:SetCondition(c94136469.indcon)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方怪兽攻击宣言时
function c94136469.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言的怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位
function c94136469.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	local rec=math.ceil(e:GetHandler():GetDefense()/2)
	-- 设置回复生命值的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复生命值的操作信息，数值为该卡守备力的一半
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果①的效果处理：特殊召唤此卡，并回复生命值
function c94136469.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡在效果处理时仍存在于手卡，则将其表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取回复生命值的目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local rec=math.ceil(c:GetDefense()/2)
		-- 中断效果处理，使特殊召唤与回复生命值不视为同时进行
		Duel.BreakEffect()
		-- 回复目标玩家等同于此卡守备力一半数值的基本分
		Duel.Recover(p,rec,REASON_EFFECT)
	end
end
-- 效果②的适用条件：这张卡在场上表侧攻击表示存在
function c94136469.indcon(e)
	return e:GetHandler():IsAttackPos()
end
