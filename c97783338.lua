--水雷魔神－ゲート・ガーディアン
-- 效果：
-- 「水魔神-斯迦」＋「雷魔神-桑迦」
-- 把自己场上的上记的卡除外的场合才能特殊召唤。这个卡名的①的效果1回合可以使用最多2次。
-- ①：自己·对方回合，以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽的攻击力直到回合结束时变成0。
-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「水魔神-斯迦」或「雷魔神-桑迦」特殊召唤。
function c97783338.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「水魔神-斯迦」和「雷魔神-桑迦」
	aux.AddFusionProcCode2(c,25955164,98434877,true,true)
	-- 添加接触融合召唤手续：将自己场上的素材表侧表示除外
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：自己·对方回合，以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97783338,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(2,97783338)
	-- 设置发动条件为伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c97783338.atktg)
	e1:SetOperation(c97783338.atkop)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「水魔神-斯迦」或「雷魔神-桑迦」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97783338,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c97783338.spcon)
	e2:SetTarget(c97783338.sptg)
	e2:SetOperation(c97783338.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动准备与目标选择函数
function c97783338.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查当前指向的对象是否为对方场上表侧表示且攻击力大于0的怪兽
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.nzatk(chkc) end
	-- 检查对方场上是否存在可以作为对象的攻击力不为0的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil)
		and c:GetFlagEffect(97783338)==0 end
	c:RegisterFlagEffect(97783338,RESET_CHAIN,0,1)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只攻击力不为0的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理函数
function c97783338.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:GetAttack()>0 then
		-- 那只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 检查这张卡是否为特殊召唤的表侧表示怪兽，且因对方从场上离开
function c97783338.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤除外状态的「水魔神-斯迦」或「雷魔神-桑迦」且可以特殊召唤的卡
function c97783338.spfilter(c,e,tp)
	return c:IsCode(25955164,98434877) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与目标选择函数
function c97783338.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外状态中是否存在符合条件的「水魔神-斯迦」或「雷魔神-桑迦」
		and Duel.IsExistingMatchingCard(c97783338.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，准备从除外状态特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果②的效果处理函数
function c97783338.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外状态的1只「水魔神-斯迦」或「雷魔神-桑迦」
	local g=Duel.SelectMatchingCard(tp,c97783338.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
