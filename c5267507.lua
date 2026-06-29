--地縛神 スカーレッド・ノヴァ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「地缚神」怪兽在场上只能有1只表侧表示存在。
-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。
-- ●从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
-- ●从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 注册地缚神场上仅存1只表侧规则、以及主要阶段除外自身送墓场上/手卡地缚神或红莲魔龙以特召地缚怪兽或真红莲新星龙的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「红莲魔龙」（卡片密码：70902743）与「真红莲新星龙」（卡片密码：97489701）
	aux.AddCodeList(c,70902743,97489701)
	-- 注册「地缚神」怪兽在场上只能有一只表侧表示存在的唯一场上规则约束
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,0x1021),LOCATION_MZONE)
	-- ②：自己·对方的主要阶段，把手卡·墓地的这张卡除外才能发动。从自己的手卡·场上（表侧表示）把1只「地缚神」怪兽或「红莲魔龙」送去墓地。那之后，可以从以下效果让1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 限制此效果只能在自己或对方的主要阶段发起发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否属于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 将手卡或墓地的此卡自身除外作为效果发动的代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将此卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 手卡或场上表侧表示存在的、可送入墓地的「红莲魔龙」或「地缚神」怪兽的过滤条件
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave() and (c:IsCode(70902743) or (c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER)))
end
-- 送墓怪兽效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可以送入墓地的「地缚神」或「红莲魔龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置操作信息为将怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 卡组或额外卡组中属于「地缚」字段的可特召怪兽、或者额外卡组中可当作同调召唤特召的「真红莲新星龙」的过滤条件
function s.spfilter(c,e,tp)
	return ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x21))
		or (c:IsCode(97489701) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)))
		-- 确认若从卡组特召，自己常规怪兽格是否有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 确认若从额外卡组特召，自己额外怪兽格是否有空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 送墓素材卡片以及此后特召地缚怪兽或「真红莲新星龙」的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡或场上选择1只符合条件的怪兽送去墓地
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	-- 将选择的怪兽送入墓地，若成功送入墓地，则确认额外/卡组是否存在可用目标并询问玩家是否进行特召
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查卡组或额外卡组中是否存有能够被召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否决定继续从卡组或额外特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 向玩家提示选择需要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组或额外卡组选择1只符合条件的怪兽进行特殊召唤
		local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if spc then
			if spc:IsCode(97489701) then
				-- 如果选择的是「真红莲新星龙」，则将其当作同调召唤进行特殊召唤并为其注册正规召唤手续
				if Duel.SpecialSummon(spc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					spc:CompleteProcedure()
				end
			else
				-- 如果选择的是常规「地缚」怪兽，将其以表侧表示特殊召唤到场上
				Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
