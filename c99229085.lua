--ギミック・パペット－カトル・スクリーム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上1个超量素材取除才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：持有这张卡作为素材中的「机关傀儡」超量怪兽得到以下效果。
-- ●1回合1次，以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
local s,id,o=GetID()
-- 注册①的自体特殊召唤效果和②作为超量素材时赋予超量怪兽的效果
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把自己场上1个超量素材取除才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤这张卡"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的「机关傀儡」超量怪兽得到以下效果。●1回合1次，以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选对方墓地怪兽在对方场上特殊召唤（机关傀儡-悲鸣四方牛）"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：把自己场上1个超量素材取除。先检查能否取除，然后实际取除
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查能否把自己场上1个超量素材取除作为发动代价
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 把自己场上1个超量素材取除作为代价
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- ①效果发动时点：检查自己主要怪兽区是否有空位，且这张卡能否被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息，通知系统将特殊召唤这张卡，用于后续连锁判定
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将这张卡特殊召唤，若成功则赋予其‘从场上离开的场合除外’的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关，并尝试以表侧表示特殊召唤，成功则继续附加除外效果
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：持有这张卡作为素材中的「机关傀儡」超量怪兽得到以下效果。●1回合1次，以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件：拥有这张卡作为素材的超量怪兽是「机关傀儡」怪兽
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x1083)
end
-- 筛选条件：对方墓地中的怪兽能否以表侧守备表示特殊召唤到对方场上
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ②效果发动时点：检查对方场上主要怪兽区有空位，且对方墓地存在1只满足特殊召唤条件的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.filter(chkc,e,tp) end
	-- 检查对方场上主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在1只满足特殊召唤条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向操作者显示‘请选择要特殊召唤的卡’的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 向对方玩家提示己方选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将选择的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将作为对象的对方墓地怪兽以表侧守备表示特殊召唤到对方场上
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁处理的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧守备表示特殊召唤到对方场上
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
