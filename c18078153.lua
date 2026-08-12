--生ける屍の軍団
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「活死人的呼声」存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「活死人的呼声」为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化函数：注册卡名记载（活死人的呼声），并创建注册①起动效果（手卡·墓地存在时可特殊召唤自身）和②诱发选发效果（送去墓地时取墓地「活死人的呼声」为对象盖放）
function s.initial_effect(c)
	-- 记录这张卡上记载着「活死人的呼声」（卡号97077563）这一卡名的事实
	aux.AddCodeList(c,97077563)
	-- ①：这张卡在手卡·墓地存在，自己场上有「活死人的呼声」存在的场合才能发动。这张卡特殊召唤。
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
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「活死人的呼声」为对象才能发动。那张卡在自己场上盖放。
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
-- 过滤条件函数：卡是「活死人的呼声」（卡号97077563）且为正面表示
function s.cfilter(c)
	return c:IsCode(97077563) and c:IsFaceup()
end
-- ①效果的发动条件：检查自己场上是否存在正面表示的「活死人的呼声」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（LOCATION_ONFIELD）是否存在至少1张满足条件的卡（正面表示的「活死人的呼声」）
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的对象函数：发动可能判定时检查自己主要怪兽区有空位且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动可能判定时：确认自己主要怪兽区有1个以上可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁确定要特殊召唤这张卡（1张）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：这张卡仍与连锁关联且不受王家长眠之谷影响时，将其攻击表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁关联，且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以正面表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件函数：卡是「活死人的呼声」（卡号97077563）且可以盖放
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- ②效果的对象函数：选取自己墓地1张可以盖放的「活死人的呼声」为对象，并设置涉及墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 发动可能判定时：检查自己墓地是否存在可以作为对象的、可盖放的「活死人的呼声」
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示“请选择要盖放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张满足条件的「活死人的呼声」作为本效果的对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次连锁将使作为对象的卡离开墓地（1张）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的处理函数：取得对象卡，若其仍与连锁关联且不受王家长眠之谷影响，则将其盖放在自己场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（自己墓地的「活死人的呼声」）
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前连锁关联，且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将作为对象的「活死人的呼声」在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
