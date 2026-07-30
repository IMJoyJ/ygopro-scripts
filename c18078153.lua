--生ける屍の軍団
-- 效果：
-- 自己场上有「活死人的呼声」存在，这张卡在自己手卡·墓地存在的场合：可以把这张卡特殊召唤。
-- 这张卡被送去墓地的场合：可以以自己墓地1张「活死人的呼声」为对象；那张卡在自己场上盖放。
-- 「活死人的军势」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建效果，注册两个效果，分别为特殊召唤和盖放效果
function s.initial_effect(c)
	-- 记录该卡具有「活死人的呼声」的卡名
	aux.AddCodeList(c,97077563)
	-- 设置第一个效果为起动效果，可以将此卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 设置第二个效果为诱发即时效果，当此卡被送去墓地时发动，可以将墓地的「活死人的呼声」盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断场上是否存在正面表示的「活死人的呼声」
function s.cfilter(c)
	return c:IsCode(97077563) and c:IsFaceup()
end
-- 判断条件函数，检查自己场上有无正面表示的「活死人的呼声」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有无正面表示的「活死人的呼声」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤效果的目标处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 设置特殊召唤效果的操作函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤函数，用于判断墓地的卡是否为「活死人的呼声」且可以盖放
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- 设置盖放效果的目标处理函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 检查自己墓地是否有满足条件的「活死人的呼声」
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标卡为墓地的一张「活死人的呼声」
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 设置盖放效果的操作函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否与连锁相关且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 执行盖放操作
		Duel.SSet(tp,tc)
	end
end
