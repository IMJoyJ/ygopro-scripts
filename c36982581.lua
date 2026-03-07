--リチュアの氷魔鏡
-- 效果：
-- 「遗式」仪式怪兽的降临必需。
-- ①：对方场上1只表侧表示怪兽解放或者等级合计直到变成和仪式召唤的怪兽相同为止把自己的手卡·场上的怪兽解放，从手卡把1只「遗式」仪式怪兽仪式召唤，自己失去那个原本攻击力数值的基本分。
-- ②：这张卡在墓地存在的场合，以自己墓地1只「遗式」怪兽为对象才能发动。那只怪兽回到卡组最上面，这张卡回到卡组最下面。
function c36982581.initial_effect(c)
	-- 效果①：对方场上1只表侧表示怪兽解放或者等级合计直到变成和仪式召唤的怪兽相同为止把自己的手卡·场上的怪兽解放，从手卡把1只「遗式」仪式怪兽仪式召唤，自己失去那个原本攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36982581.target)
	e1:SetOperation(c36982581.activate)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在墓地存在的场合，以自己墓地1只「遗式」怪兽为对象才能发动。那只怪兽回到卡组最上面，这张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c36982581.tdtg)
	e2:SetOperation(c36982581.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查手卡中是否包含「遗式」卡组的怪兽
function c36982581.rfilter1(c,e,tp)
	return c:IsSetCard(0x3a)
end
-- 过滤函数：检查手卡中是否包含「遗式」卡组的仪式怪兽且可特殊召唤
function c36982581.rfilter2(c,e,tp)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsSetCard(0x3a) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
-- 过滤函数：检查对方场上是否包含可因效果解放的表侧表示怪兽
function c36982581.cfilter(c,e,tp)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsReleasableByEffect() and c:IsControler(tp)
end
-- 效果①的发动条件判断：检查是否存在满足条件的「遗式」仪式怪兽可从手卡仪式召唤，或是否存在可解放的对方怪兽进行仪式召唤
function c36982581.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的用于仪式召唤的素材卡片组（包括手卡、场上、墓地的仪式魔人等）
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取对方场上可因效果解放的表侧表示怪兽组
		local mg2=Duel.GetReleaseGroup(1-tp,false,REASON_EFFECT):Filter(c36982581.cfilter,nil,e,1-tp)
		-- 检查是否存在满足条件的「遗式」仪式怪兽可从手卡仪式召唤
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c36982581.rfilter1,e,tp,mg1,nil,Card.GetLevel,"Equal")
			-- 检查是否存在可解放的对方怪兽进行仪式召唤
			or (mg2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查是否存在满足条件的「遗式」仪式怪兽可从手卡仪式召唤
				and Duel.IsExistingMatchingCard(c36982581.rfilter2,tp,LOCATION_HAND,0,1,nil,e,tp))
	end
	-- 设置效果处理时要处理的特殊召唤对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理函数：选择要特殊召唤的仪式怪兽并进行仪式召唤
function c36982581.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	-- 获取玩家可用的用于仪式召唤的素材卡片组（包括手卡、场上、墓地的仪式魔人等）
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取对方场上可因效果解放的表侧表示怪兽组
	local mg2=Duel.GetReleaseGroup(1-tp,false,REASON_EFFECT):Filter(c36982581.cfilter,nil,e,1-tp)
	-- 获取满足条件的「遗式」仪式怪兽组（从手卡中可特殊召唤的）
	local g1=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c36982581.rfilter1,e,tp,mg1,nil,Card.GetLevel,"Equal")
	local g2=nil
	local g=g1
	-- 检查是否存在可解放的对方怪兽进行仪式召唤
	if mg2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取满足条件的「遗式」仪式怪兽组（从手卡中可特殊召唤的）
		g2=Duel.GetMatchingGroup(c36982581.rfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		g=g1+g2
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 判断是否选择使用对方怪兽进行仪式召唤
		if g1:IsContains(tc) and (not g2 or (g2:IsContains(tc) and not Duel.SelectYesNo(tp,aux.Stringid(36982581,0)))) then  --"是否解放对方的1只怪兽来仪式召唤？"
			-- 提示玩家选择要解放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			-- 设置仪式召唤的附加检查函数
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
			-- 从可用素材中选择满足条件的仪式召唤素材组
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			-- 清除仪式召唤的附加检查函数
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 解放仪式召唤所用的素材
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 提示玩家选择要解放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			local matc=mg2:SelectUnselect(nil,tp,false,true,1,1)
			if not matc then goto cancel end
			local mat=Group.FromCards(matc)
			tc:SetMaterial(mat)
			-- 解放仪式召唤所用的素材
			Duel.ReleaseRitualMaterial(mat)
		end
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 将选择的仪式怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
			-- 失去该仪式怪兽原本攻击力数值的基本分
			Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetBaseAttack())
			tc:CompleteProcedure()
		end
	end
end
-- 过滤函数：检查墓地中是否包含「遗式」卡组的怪兽且可送回卡组
function c36982581.tdfilter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动条件判断：检查是否存在满足条件的「遗式」怪兽可送回卡组
function c36982581.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36982581.tdfilter(chkc) end
	-- 检查是否存在满足条件的「遗式」怪兽可送回卡组
	if chk==0 then return Duel.IsExistingTarget(c36982581.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择要返回卡组的「遗式」怪兽
	local g=Duel.SelectTarget(tp,c36982581.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	-- 设置效果处理时要处理的送回卡组对象
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的处理函数：将目标怪兽和自身送回卡组
function c36982581.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽和自身是否仍存在于场上或墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将自身送回卡组最下面
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
