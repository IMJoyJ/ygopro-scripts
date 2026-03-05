--キング・もけもけ
-- 效果：
-- 「悠悠」＋「悠悠」＋「悠悠」
-- 这张卡从场上离开时，可以把自己墓地存在的「悠悠」尽可能多的特殊召唤。
function c13803864.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个卡号为27288416的怪兽作为融合素材
	aux.AddFusionProcCodeRep(c,27288416,3,true,true)
	-- 这张卡从场上离开时，可以把自己墓地存在的「悠悠」尽可能多的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13803864,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(c13803864.spcon)
	e1:SetTarget(c13803864.sptg)
	e1:SetOperation(c13803864.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断墓地中的卡是否为「悠悠」且可以特殊召唤
function c13803864.spfilter(c,e,tp)
	return c:IsCode(27288416) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件，判断此卡是否以正面表示从场上离开
function c13803864.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果目标设定函数，用于确定特殊召唤的卡的范围
function c13803864.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查墓地是否存在至少1张「悠悠」卡
		and Duel.IsExistingMatchingCard(c13803864.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡的类型为CATEGORY_SPECIAL_SUMMON
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行特殊召唤操作
function c13803864.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足条件的墓地中的「悠悠」卡组
	local tg=Duel.GetMatchingGroup(c13803864.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=tg:Select(tp,ft,ft,nil)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
