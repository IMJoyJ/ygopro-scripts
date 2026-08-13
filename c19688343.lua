--バーニングナックル・クロスカウンター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把怪兽的效果发动时才能发动。自己场上1只「燃烧拳击手」超量怪兽或「No.」超量怪兽破坏，那个发动无效并破坏。那之后，以下效果可以适用。
-- ●和破坏的自己怪兽卡名不同的1只「燃烧拳击手」超量怪兽从额外卡组特殊召唤，把这张卡作为那只怪兽的超量素材。
function c19688343.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方把怪兽的效果发动时才能发动。自己场上1只「燃烧拳击手」超量怪兽或「No.」超量怪兽破坏，那个发动无效并破坏。那之后，以下效果可以适用。●和破坏的自己怪兽卡名不同的1只「燃烧拳击手」超量怪兽从额外卡组特殊召唤，把这张卡作为那只怪兽的超量素材。
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
-- 定义本卡的发动条件函数，用于判断当前连锁是否满足「对方把怪兽的效果发动时」且该连锁可以被无效。
function c19688343.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件判定：对方玩家（rp==1-tp）发动的是怪兽效果（re:IsActiveType(TYPE_MONSTER)），且该连锁能够被无效（Duel.IsChainNegatable(ev)）。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义可选择破坏的怪兽的筛选条件：自己场上表侧表示的持有「燃烧拳击手」或「No.」字段的超量怪兽。
function c19688343.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48,0x1084) and c:IsType(TYPE_XYZ)
end
-- 定义效果发动时的目标/合法性处理：检查己方是否存在可破坏的超量怪兽，并预先设置无效对方连锁与破坏对象（包含己方怪兽及对方的效果怪兽）的操作信息。
function c19688343.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0），确认己方场上存在至少1只表侧表示的「燃烧拳击手」或「No.」超量怪兽可供破坏，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19688343.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：本连锁包含『无效效果』类别，对象为对方发动的怪兽效果（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 取得己方场上所有满足破坏条件的超量怪兽，作为后续破坏对象的候选集合。
	local g=Duel.GetMatchingGroup(c19688343.desfilter,tp,LOCATION_MZONE,0,nil)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		g:Merge(eg)
	end
	-- 设置操作信息：本连锁包含『破坏』类别，破坏对象为集合g（含己方超量怪兽，若对方的怪兽可破坏也已加入），数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 定义可特殊召唤的额外卡组怪兽的筛选条件：是「燃烧拳击手」超量怪兽，卡名与破坏的己方怪兽不同，且能够被本次效果特殊召唤并有足够额外怪兽区空格。
function c19688343.spfilter(c,e,tp,code)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_XYZ) and not c:IsCode(code)
		-- 追加判定该怪兽可以被当前效果特殊召唤，且我方存在可供额外卡组超量怪兽特殊召唤的空余区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义效果处理流程：选择并破坏己方1只「燃烧拳击手」或「No.」超量怪兽，将对方发动的怪兽效果无效并破坏发动效果的那只怪兽；若处理成功，则询问是否适用后续特殊召唤效果，适用时将追加特殊召唤1只符合条件的「燃烧拳击手」超量怪兽并把本卡作为素材叠放。
function c19688343.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，提示内容为『请选择要破坏的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从己方场上选择1只满足desfilter条件的超量怪兽（即要破坏的卡）。
	local dg=Duel.SelectMatchingCard(tp,c19688343.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=dg:GetFirst()
	if tc then
		-- 为选中的卡展示选中动画，并记录这些卡被选为对象，供其他连锁/效果判定。
		Duel.HintSelection(dg)
		-- 破坏所选己方怪兽，若破坏成功且使对方连锁的发动无效成功，继续处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.NegateActivation(ev)
			-- 进一步确认对方发动效果的怪兽仍与该效果相关（未离场）且被破坏成功，全部满足才进入后续特殊召唤分支。
			and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
			local c=e:GetHandler()
			-- 从额外卡组筛选出所有可特殊召唤的「燃烧拳击手」超量怪兽，且卡名与已被破坏的己方怪兽（tc）的卡名不同。
			local g=Duel.GetMatchingGroup(c19688343.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc:GetCode())
			if g:GetCount()>0 and c:IsRelateToChain() and c:IsCanOverlay()
				-- 在存在可特殊召唤对象、本卡仍与连锁相关且可作为超量素材时，询问玩家是否适用后续从额外卡组特殊召唤的效果。
				and Duel.SelectYesNo(tp,aux.Stringid(19688343,0)) then  --"是否从额外卡组特殊召唤？"
				-- 中断当前效果处理，使后续特殊召唤与之前的破坏/无效处理视为不同时处理，以正确形成新的时点。
				Duel.BreakEffect()
				-- 显示选择提示，提示内容为『请选择要特殊召唤的卡』。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sc=g:Select(tp,1,1,nil):GetFirst()
				-- 将选择的超量怪兽以表侧攻击表示特殊召唤到己方场上，若特殊召唤成功（返回非0）则继续执行叠放。
				if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
					c:CancelToGrave()
					-- 把本卡（燃烧拳交叉反击）作为超量素材叠放在特殊召唤出的超量怪兽sc下方。
					Duel.Overlay(sc,c)
				end
			end
		end
	end
end
