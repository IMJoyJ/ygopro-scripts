--サクリファイス・ランクアップ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只超量怪兽为对象才能发动。那只怪兽2个超量素材除外，比那只怪兽阶级高1阶的1只超量怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c94185340.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只超量怪兽为对象才能发动。那只怪兽2个超量素材除外，比那只怪兽阶级高1阶的1只超量怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94185340,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,94185340+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c94185340.target)
	e1:SetOperation(c94185340.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、拥有2个以上超量素材、且额外卡组存在比其阶级高1阶的超量怪兽的超量怪兽
function c94185340.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=2
		-- 检查额外卡组是否存在比该怪兽阶级高1阶且可以特殊召唤的超量怪兽
		and Duel.IsExistingMatchingCard(c94185340.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk+1)
end
-- 过滤额外卡组中阶级符合要求且可以特殊召唤的超量怪兽
function c94185340.filter2(c,e,tp,rk)
	-- 检查怪兽是否为指定阶级、是否可以特殊召唤，以及额外卡组怪兽出场的可用怪兽区域是否足够
	return c:IsRank(rk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的对象选择与可行性检查
function c94185340.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c94185340.filter1(chkc,e,tp) end
	-- 检查玩家当前是否可以除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 检查自己场上是否存在满足条件的超量怪兽作为对象
		and Duel.IsExistingTarget(c94185340.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只超量怪兽作为对象
	Duel.SelectTarget(tp,c94185340.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c94185340.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g=tc:GetOverlayGroup()
	-- 提示玩家选择要除外的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:FilterSelect(tp,Card.IsAbleToRemove,2,2,nil,POS_FACEUP)
	-- 将选中的2个超量素材表侧表示除外，并确认除外成功且对象怪兽仍在场上表侧表示
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==2 and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只比对象怪兽阶级高1阶的超量怪兽
		local sg=Duel.SelectMatchingCard(tp,c94185340.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank()+1)
		local sc=sg:GetFirst()
		-- 将选择的怪兽以表侧表示特殊召唤
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(94185340,1))  --"「牲祭升阶」的效果特殊召唤"
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
