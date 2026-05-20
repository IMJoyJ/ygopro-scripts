--調律の魔術師
-- 效果：
-- 「调律之魔术师」的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己的灵摆区域有2张「魔术师」卡存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡召唤·特殊召唤成功的场合发动。对方回复400基本分，那之后自己受到400伤害。
function c54941203.initial_effect(c)
	-- 「调律之魔术师」的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，自己的灵摆区域有2张「魔术师」卡存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54941203,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,54941203)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c54941203.spcon)
	e1:SetTarget(c54941203.sptg)
	e1:SetOperation(c54941203.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合发动。对方回复400基本分，那之后自己受到400伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTarget(c54941203.rectg)
	e2:SetOperation(c54941203.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件检查函数
function c54941203.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在2张「魔术师」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0x98)
end
-- 效果①的发动准备与合法性检查函数
function c54941203.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数（特殊召唤自身并添加离场除外效果）
function c54941203.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤，若特殊召唤成功则进行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡召唤·特殊召唤成功的场合发动。对方回复400基本分，那之后自己受到400伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 效果②的发动准备与合法性检查函数
function c54941203.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果的目标玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置回复的操作信息，表示对方玩家回复400基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,400)
	-- 设置伤害的操作信息，表示自己受到400伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
end
-- 效果②的效果处理函数（对方回复400基本分，那之后自己受到400伤害）
function c54941203.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让目标玩家回复400基本分，若回复成功则进行后续处理
	if Duel.Recover(p,400,REASON_EFFECT)~=0 then
		-- 中断效果处理，使后续的伤害处理与回复处理不视为同时进行（对应“那之后”的时点）
		Duel.BreakEffect()
		-- 给与自己400点伤害
		Duel.Damage(tp,400,REASON_EFFECT)
	end
end
