--リチュアの氷魔鏡
-- 效果：
-- 「遗式」仪式怪兽的降临必需。
-- ①：对方场上1只表侧表示怪兽解放或者等级合计直到变成和仪式召唤的怪兽相同为止把自己的手卡·场上的怪兽解放，从手卡把1只「遗式」仪式怪兽仪式召唤，自己失去那个原本攻击力数值的基本分。
-- ②：这张卡在墓地存在的场合，以自己墓地1只「遗式」怪兽为对象才能发动。那只怪兽回到卡组最上面，这张卡回到卡组最下面。
function c36982581.initial_effect(c)
	-- ①：对方场上1只表侧表示怪兽解放或者等级合计直到变成和仪式召唤的怪兽相同为止把自己的手卡·场上的怪兽解放，从手卡把1只「遗式」仪式怪兽仪式召唤，自己失去那个原本攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36982581.target)
	e1:SetOperation(c36982581.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只「遗式」怪兽为对象才能发动。那只怪兽回到卡组最上面，这张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c36982581.tdtg)
	e2:SetOperation(c36982581.tdop)
	c:RegisterEffect(e2)
end
-- 该过滤器用于筛选可作为仪式召唤对象的「遗式」仪式怪兽，要求其卡名字段属于「遗式」（0x3a）。
function c36982581.rfilter1(c,e,tp)
	return c:IsSetCard(0x3a)
end
-- 该过滤器用于筛选可以通过解放对方怪兽作为追加素材来仪式召唤的「遗式」仪式怪兽，要求其为仪式怪兽、属于「遗式」字段且能够满足仪式特殊召唤条件。
function c36982581.rfilter2(c,e,tp)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsSetCard(0x3a) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
-- 该过滤器用于筛选对方场上可作为仪式召唤解放素材的表侧表示怪兽，要求不免疫此效果、能够被效果解放且由对方控制。
function c36982581.cfilter(c,e,tp)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsReleasableByEffect() and c:IsControler(tp)
end
-- 效果①的发动合法性检查：确认手卡中存在「遗式」仪式怪兽，且可通过通常仪式素材（自己的手卡·场上怪兽）或解放对方场上表侧怪兽的方式满足仪式召唤条件，并设置从手卡特殊召唤1只怪兽的操作信息。
function c36982581.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 在发动合法性检查中，获取己方可用的仪式召唤解放素材组（包括手卡、场上及墓地仪式魔人等），用于判断能否以通常仪式素材进行仪式召唤。
		local mg1=Duel.GetRitualMaterial(tp)
		-- 在发动合法性检查中，获取对方场上可被效果解放的表侧表示怪兽组，用于判断能否通过解放对方怪兽来满足仪式召唤的追加素材条件。
		local mg2=Duel.GetReleaseGroup(1-tp,false,REASON_EFFECT):Filter(c36982581.cfilter,nil,e,1-tp)
		-- 检查手卡中是否存在一只「遗式」仪式怪兽，能够仅使用己方仪式素材（mg1）且素材等级合计与仪式怪兽等级相等的方式进行仪式召唤。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c36982581.rfilter1,e,tp,mg1,nil,Card.GetLevel,"Equal")
			-- 或者，检查是否存在对方场上的可解放怪兽，并且己方场上有足够的主要怪兽区域空位，以满足第二种仪式召唤路线的前提条件。
			or (mg2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 并且，在手卡中是否存在一只可用“解放对方怪兽”方式满足仪式召唤条件的「遗式」仪式怪兽（通过rfilter2筛选）。
				and Duel.IsExistingMatchingCard(c36982581.rfilter2,tp,LOCATION_HAND,0,1,nil,e,tp))
	end
	-- 设置当前连锁的操作信息：本次效果将从手卡特殊召唤1只怪兽（类别为特殊召唤），供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的实际处理流程：先后选择要仪式召唤的「遗式」仪式怪兽及解放素材（己方素材或对方1只怪兽），解放素材后以仪式召唤方式特殊召唤该怪兽，并按该怪兽原本攻击力数值扣除自己基本分。
function c36982581.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	-- 在效果处理时，重新获取己方可用的仪式召唤解放素材组，用于实际选择本次解放的己方手卡·场上的怪兽。
	local mg1=Duel.GetRitualMaterial(tp)
	-- 在效果处理时，重新获取对方场上可被效果解放的表侧表示怪兽组，用于“解放对方1只怪兽”的仪式召唤路线。
	local mg2=Duel.GetReleaseGroup(1-tp,false,REASON_EFFECT):Filter(c36982581.cfilter,nil,e,1-tp)
	-- 筛选手卡中可以使用己方通常仪式素材（mg1）且等级合计恰好等于仪式怪兽等级来仪式召唤的「遗式」仪式怪兽集合。
	local g1=Duel.GetMatchingGroup(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,nil,c36982581.rfilter1,e,tp,mg1,nil,Card.GetLevel,"Equal")
	local g2=nil
	local g=g1
	-- 如果存在对方场上可解放的表侧表示怪兽，并且己方场上有空位，则将“解放对方怪兽”作为可选路线加入本次仪式召唤候选。
	if mg2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 筛选手卡中能够通过解放对方1只怪兽来满足仪式召唤条件的「遗式」仪式怪兽集合。
		g2=Duel.GetMatchingGroup(c36982581.rfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		g=g1+g2
	end
	-- 向玩家发送“请选择要特殊召唤的卡”的提示信息，用于从候选仪式怪兽中进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 判断是否走“解放自己的手卡·场上怪兽”的通常路线：当选中的怪兽不在对方解放路线候选内，或玩家选择不解放对方怪兽（即对“是否解放对方的1只怪兽来仪式召唤？”选否）时，进入己方素材解放流程。
		if g1:IsContains(tc) and (not g2 or (g2:IsContains(tc) and not Duel.SelectYesNo(tp,aux.Stringid(36982581,0)))) then  --"是否解放对方的1只怪兽来仪式召唤？"
			-- 向玩家发送“请选择要解放的卡”的提示信息，用于从己方仪式素材中选择解放对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			-- 临时设置仪式素材选择的额外等级校验辅助函数，确保所选素材的等级合计必须与仪式怪兽的等级完全相同（Equal）。
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
			-- 从己方可用仪式素材中选择一组等级合计满足要求（等于仪式怪兽等级）的素材作为本次仪式召唤的解放代价。
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			-- 清除自定义的素材等级校验辅助函数，避免对后续其他选择造成影响。
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 解放选定的己方仪式召唤素材（手卡·场上的怪兽，或墓地仪式魔人等特殊素材按规则除外）。
			Duel.ReleaseRitualMaterial(mat)
		else
			-- 向玩家发送“请选择要解放的卡”的提示信息，用于选择对方场上的1只表侧表示怪兽作为解放对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			local matc=mg2:SelectUnselect(nil,tp,false,true,1,1)
			if not matc then goto cancel end
			local mat=Group.FromCards(matc)
			tc:SetMaterial(mat)
			-- 解放对方场上被选中的1只表侧表示怪兽，作为本次仪式召唤的追加素材。
			Duel.ReleaseRitualMaterial(mat)
		end
		-- 中断当前效果的处理流程，使后续的仪式召唤处理被视为独立效果处理，从而不会错过仪式召唤成功时的时点。
		Duel.BreakEffect()
		-- 以仪式召唤方式将选中的「遗式」仪式怪兽特殊召唤到己方场上；若特殊召唤成功，则继续执行扣血处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
			-- 自己失去该仪式怪兽原本攻击力数值的基本分（即LP减去原本攻击力）。
			Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetBaseAttack())
			tc:CompleteProcedure()
		end
	end
end
-- 该过滤器用于筛选墓地中满足条件的「遗式」怪兽：属于「遗式」字段、是怪兽卡且能够返回卡组。
function c36982581.tdfilter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动合法性检查和取对象处理：以自己墓地1只「遗式」怪兽为对象，且此卡自身能够返回卡组，并设置将对象和此卡返回卡组的操作信息。
function c36982581.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36982581.tdfilter(chkc) end
	-- 效果②的发动合法性检查：确认自己墓地存在至少1只满足条件的「遗式」怪兽，并且这张冰魔镜自身能够返回卡组。
	if chk==0 then return Duel.IsExistingTarget(c36982581.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	-- 向玩家发送“请选择要返回卡组的卡”的提示信息，用于从墓地的「遗式」怪兽中选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只满足条件的「遗式」怪兽作为效果对象（取对象），同时自动建立对象与当前连锁的关联。
	local g=Duel.SelectTarget(tp,c36982581.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	-- 设置操作信息：将选中的对象怪兽和此卡（冰魔镜）返回卡组，数量为对象组中的卡数（此处为2），类别为返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的实际处理：先将对象怪兽返回持有者卡组最上面，若成功且此卡仍与效果关联，再将此卡返回持有者卡组最下面。
function c36982581.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②取对象时选择的那只墓地「遗式」怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果关联，并且成功返回卡组最上面，同时此卡（冰魔镜）仍与效果关联，则继续执行此卡返回卡组最下面的处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张冰魔镜从墓地返回持有者卡组最下面。
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
