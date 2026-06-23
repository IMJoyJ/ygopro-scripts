--クリアー・キューブ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把有「清透世界」的卡名记述的1只怪兽召唤。
-- ③：表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组把有「清透世界」的卡名记述的1只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果
function s.initial_effect(c)
	-- 记录该卡记载了「清透世界」（卡号33900648）
	aux.AddCodeList(c,33900648)
	-- 只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetCode(97811903)
	c:RegisterEffect(e1)
	-- 自己在通常召唤外加上只有1次，自己主要阶段可以把有「清透世界」的卡名记述的1只怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(s.suntg)
	c:RegisterEffect(e2)
	-- 表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组把有「清透世界」的卡名记述的1只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为「清透世界」相关怪兽
function s.suntg(e,c)
	-- 判断目标怪兽是否为「清透世界」相关怪兽
	return aux.IsCodeListed(c,33900648)
end
-- 判断该卡是否因对方操作而离场
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 筛选卡组中可特殊召唤的「清透世界」相关怪兽
function s.spfilter(c,e,tp)
	-- 筛选卡组中可特殊召唤的「清透世界」相关怪兽
	return aux.IsCodeListed(c,33900648) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
