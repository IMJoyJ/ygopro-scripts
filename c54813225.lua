--ダックファイター
-- 效果：
-- 把自己场上的衍生物那个等级合计直到3以上解放才能发动。这张卡从手卡或者墓地特殊召唤。「野鸭战斗机」的效果1回合只能使用1次。
function c54813225.initial_effect(c)
	-- 把自己场上的衍生物那个等级合计直到3以上解放才能发动。这张卡从手卡或者墓地特殊召唤。「野鸭战斗机」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54813225,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,54813225)
	e1:SetCost(c54813225.spcost)
	e1:SetTarget(c54813225.sptg)
	e1:SetOperation(c54813225.spop)
	c:RegisterEffect(e1)
end
-- 定义解放怪兽的合法性检查函数，判断选中的怪兽等级合计是否在3以上，且解放后主怪兽区是否有空位
function c54813225.relgoal(sg,tp)
	-- 设置当前已选中的卡片组，用于后续的CheckWithSumGreater判定
	Duel.SetSelectedCard(sg)
	-- 检查选中的卡片等级合计是否大于等于3，且解放这些卡后主怪兽区是否有足够的空位特殊召唤
	return sg:CheckWithSumGreater(Card.GetLevel,3) and aux.mzctcheckrel(sg,tp)
end
-- 定义效果发动代价，检查并从场上选择等级合计在3以上的衍生物解放
function c54813225.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可以被解放的衍生物卡片组
	local mg=Duel.GetReleaseGroup(tp):Filter(Card.IsType,nil,TYPE_TOKEN)
	if chk==0 then return mg:CheckSubGroup(c54813225.relgoal,1,3,tp) end
	-- 给玩家发送提示信息，提示选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=mg:SelectSubGroup(tp,c54813225.relgoal,false,1,3,tp)
	-- 应用代替解放的效果次数（如暗影敌托邦等效果）
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 定义效果发动目标，检查自身是否可以特殊召唤并设置特殊召唤的操作信息
function c54813225.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数，将这张卡特殊召唤
function c54813225.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
