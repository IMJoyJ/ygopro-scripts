--生きる偲びのシルキィ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己以及对方场上的表侧表示怪兽各1只为对象才能发动。那些怪兽变成里侧守备表示，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c55702233.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，以自己以及对方场上的表侧表示怪兽各1只为对象才能发动。那些怪兽变成里侧守备表示，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55702233,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,55702233)
	e1:SetTarget(c55702233.sptg)
	e1:SetOperation(c55702233.spop)
	c:RegisterEffect(e1)
end
-- 效果发动时的可行性检测（检查是否存在合法的对象、怪兽区域以及自身是否能特殊召唤）
function c55702233.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以变成里侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以变成里侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 发送提示信息，要求选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只可以变成里侧表示的怪兽作为对象
	local g1=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,1,nil)
	-- 发送提示信息，要求选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只可以变成里侧表示的怪兽作为对象
	local g2=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：改变2张卡片的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将对象怪兽变成里侧守备表示，并特殊召唤自身，同时适用离场除外的约束
function c55702233.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍对效果有效的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若存在有效对象，则将它们变成里侧守备表示
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		local c=e:GetHandler()
		-- 若成功改变表示形式，且自身卡片仍对效果有效，则将自身表侧表示特殊召唤
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end
