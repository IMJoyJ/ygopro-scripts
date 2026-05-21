--闇征竜－ネビュラス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把1只龙族或暗属性的怪兽和这张卡从手卡丢弃，以「暗征龙-朦龙」以外的自己的除外状态的2只属性不同的「征龙」怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
-- ②：把1只龙族或暗属性的怪兽和这张卡从自己墓地除外，以自己墓地1只「凶征龙-食龙」为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①和效果②的注册
function s.initial_effect(c)
	-- 记录这张卡的效果中记载了「凶征龙-食龙」的卡名
	aux.AddCodeList(c,30350202)
	-- ①：把1只龙族或暗属性的怪兽和这张卡从手卡丢弃，以「暗征龙-朦龙」以外的自己的除外状态的2只属性不同的「征龙」怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把1只龙族或暗属性的怪兽和这张卡从自己墓地除外，以自己墓地1只「凶征龙-食龙」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可丢弃的龙族或暗属性怪兽
function s.dfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_DRAGON)) and c:IsDiscardable()
end
-- 效果①的发动代价判定，检查自身是否能从手卡丢弃，以及手卡中是否存在另一只可丢弃的龙族或暗属性怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查手卡中是否存在除自身以外的1只龙族或暗属性怪兽
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择手卡中除自身以外的1只龙族或暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和这张卡一起作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤除外状态的、卡名非「暗征龙-朦龙」的「征龙」怪兽，且该怪兽可以被特殊召唤并能成为效果对象
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsCanBeEffectTarget(e)
end
-- 效果①的发动准备阶段，进行合法性检查并选择2只属性不同的「征龙」怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己除外状态下满足特殊召唤条件的「征龙」怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查除外状态的「征龙」怪兽中是否存在2只属性不同的怪兽
		and g:CheckSubGroup(aux.dabcheck,2,2) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择2只属性不同的「征龙」怪兽
	local g1=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	-- 将选中的2只怪兽设为效果处理的对象
	Duel.SetTargetCard(g1)
	-- 设置连锁信息，表明此效果包含特殊召唤这2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果①的效果处理函数，将选中的怪兽特殊召唤，并施加不能攻击的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if tg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if tg:GetCount()<=ft then
		-- 遍历所有仍符合条件的怪兽对象
		for tc in aux.Next(tg) do
			-- 逐步将怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,ft,ft,nil)
		-- 遍历在格子不足时被玩家选中的、能够特殊召唤的怪兽
		for tc in aux.Next(sg) do
			-- 逐步将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tg:Sub(sg)
		-- 将因格子不足而无法特殊召唤的其余对象怪兽送去墓地
		Duel.SendtoGrave(tg,REASON_RULE)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 过滤自己墓地中可作为发动代价除外的龙族或暗属性怪兽，且要求此时墓地中存在可特殊召唤的「凶征龙-食龙」
function s.costfilter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_DRAGON)) and c:IsAbleToRemoveAsCost()
		-- 检查自己墓地中是否存在除该代价卡以外的「凶征龙-食龙」
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 效果②的发动代价函数，将自身和另1只龙族或暗属性怪兽从墓地除外
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地中是否存在可除外的龙族或暗属性怪兽，以及自身是否能从墓地除外
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择墓地中除自身以外的1只龙族或暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将墓地中的这张卡自身除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
-- 过滤墓地中可以特殊召唤的「凶征龙-食龙」
function s.spfilter2(c,e,tp)
	return c:IsCode(30350202) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备阶段，进行合法性检查并选择墓地的「凶征龙-食龙」作为对象
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查自己的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在可作为对象的「凶征龙-食龙」
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中的1只「凶征龙-食龙」作为对象
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤该怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理函数，将作为对象的「凶征龙-食龙」特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍受当前效果影响，且不受「王家长眠之谷」的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
