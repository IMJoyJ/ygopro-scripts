--バーニングナックル・クロスカウンター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把怪兽的效果发动时才能发动。自己场上1只「燃烧拳击手」超量怪兽或「No.」超量怪兽破坏，那个发动无效并破坏。那之后，以下效果可以适用。
-- ●和破坏的自己怪兽卡名不同的1只「燃烧拳击手」超量怪兽从额外卡组特殊召唤，把这张卡作为那只怪兽的超量素材。
function c19688343.initial_effect(c)
	-- 创建效果，设置效果分类为使发动无效、破坏、特殊召唤，效果类型为发动，连锁时触发，限制1回合1次，条件为对方怪兽发动效果，目标函数为c19688343.target，处理函数为c19688343.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,19688343+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19688343.condition)
	e1:SetTarget(c19688343.target)
	e1:SetOperation(c19688343.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断，对方怪兽发动效果且该连锁可被无效
function c19688343.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽发动效果且该连锁可被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 破坏过滤器，筛选场上正面表示的燃烧拳击手超量怪兽
function c19688343.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48,0x1084) and c:IsType(TYPE_XYZ)
end
-- 设置效果处理时的操作信息，包括使发动无效和破坏效果
function c19688343.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足破坏条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19688343.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置使发动无效的效果信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 获取场上满足破坏条件的怪兽组
	local g=Duel.GetMatchingGroup(c19688343.desfilter,tp,LOCATION_MZONE,0,nil)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		g:Merge(eg)
	end
	-- 设置破坏效果信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 特殊召唤过滤器，筛选额外卡组中满足条件的燃烧拳击手超量怪兽
function c19688343.spfilter(c,e,tp,code)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_XYZ) and not c:IsCode(code)
		-- 检查怪兽是否可特殊召唤且场上是否有足够召唤位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理函数，选择破坏怪兽并执行破坏、无效、特殊召唤等操作
function c19688343.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的1只怪兽作为破坏对象
	local dg=Duel.SelectMatchingCard(tp,c19688343.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=dg:GetFirst()
	if tc then
		-- 显示选中的怪兽被选为对象的动画
		Duel.HintSelection(dg)
		-- 破坏选中的怪兽并使连锁无效
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.NegateActivation(ev)
			-- 确认对方发动的怪兽存在且可破坏，并破坏对方发动的怪兽
			and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
			local c=e:GetHandler()
			-- 获取额外卡组中满足特殊召唤条件的怪兽组
			local g=Duel.GetMatchingGroup(c19688343.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc:GetCode())
			if g:GetCount()>0 and c:IsRelateToChain() and c:IsCanOverlay()
				-- 询问玩家是否从额外卡组特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(19688343,0)) then  --"是否从额外卡组特殊召唤？"
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sc=g:Select(tp,1,1,nil):GetFirst()
				-- 将选中的怪兽特殊召唤到场上
				if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
					c:CancelToGrave()
					-- 将此卡作为选中怪兽的超量素材
					Duel.Overlay(sc,c)
				end
			end
		end
	end
end
