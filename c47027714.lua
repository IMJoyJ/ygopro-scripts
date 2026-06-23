--TG ハルバード・キャノン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽以及对方场上的特殊召唤的怪兽全部除外。
-- ②：场上的这张卡被破坏时，以自己墓地1只「科技属 戟炮手」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
function c47027714.initial_effect(c)
	-- 记录该卡具有「爆裂模式」效果的卡片编号
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为通过「爆裂模式」效果发动
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽以及对方场上的特殊召唤的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47027714)
	e1:SetCondition(c47027714.rmcon)
	e1:SetTarget(c47027714.rmtg)
	e1:SetOperation(c47027714.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被破坏时，以自己墓地1只「科技属 戟炮手」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47027714,2))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,47027715)
	e4:SetCondition(c47027714.spcon)
	e4:SetTarget(c47027714.sptg)
	e4:SetOperation(c47027714.spop)
	c:RegisterEffect(e4)
end
c47027714.assault_name=97836203
-- 判断是否为对方召唤且当前无连锁处理中
function c47027714.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方召唤且当前无连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 设置效果目标及操作信息，包括无效召唤和除外怪兽
function c47027714.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 筛选出被召唤的怪兽
	local g=eg:Filter(aux.TRUE,nil,e:GetHandler())
	-- 获取对方场上所有特殊召唤的怪兽
	local g2=Duel.GetMatchingGroup(Card.IsSummonType,tp,0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	g:Merge(g2)
	-- 设置将要无效召唤的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置将要除外的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行效果操作，使召唤无效并除外相关怪兽
function c47027714.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效
	Duel.NegateSummon(eg)
	local g=eg:Clone()
	-- 获取对方场上所有特殊召唤的怪兽
	local g2=Duel.GetMatchingGroup(Card.IsSummonType,tp,0,LOCATION_MZONE,g,SUMMON_TYPE_SPECIAL)
	g:Merge(g2)
	-- 将怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 判断该卡是否从场上被破坏
function c47027714.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选墓地中的「科技属 戟炮手」卡片
function c47027714.spfilter(c,e,tp)
	return c:IsCode(97836203) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置选择目标及检查满足条件
function c47027714.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47027714.spfilter(chkc,e,tp) end
	-- 检查是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的墓地目标
		and Duel.IsExistingTarget(c47027714.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,c47027714.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c47027714.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片无视召唤条件特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
