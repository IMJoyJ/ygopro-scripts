--ЯRUM－レイド・ラプターズ・フォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段以及对方战斗阶段，以包含场上的怪兽的自己的场上·墓地的「急袭猛禽」超量怪兽2只以上为对象才能发动。把持有和那2只以上的怪兽的阶级合计相同阶级的1只「急袭猛禽」超量怪兽当作超量召唤从额外卡组特殊召唤，把作为对象的怪兽作为那超量素材（作为对象的怪兽持有超量素材的场合，那些也全部作为超量素材）。
local s,id,o=GetID()
-- 注册效果：将此卡设为发动时点效果，具有取对象、自由连锁、发动次数限制等属性
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段以及对方战斗阶段，以包含场上的怪兽的自己的场上·墓地的「急袭猛禽」超量怪兽2只以上为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 条件判断：判断当前是否为自己的主要阶段1、主要阶段2，或对方的战斗阶段开始到战斗阶段结束
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1或主要阶段2，或对方的战斗阶段开始到战斗阶段结束
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 or Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 过滤函数1：筛选场上或墓地满足条件的「急袭猛禽」超量怪兽（必须是表侧表示、有阶级、可成为效果对象、未被禁止）
function s.filter1(c,e)
	return c:GetRank()>0 and c:IsFaceup() and c:IsSetCard(0xba) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
-- 过滤函数2：筛选额外卡组中满足条件的「急袭猛禽」超量怪兽（阶级等于目标怪兽阶级总和、可特殊召唤、有召唤空位）
function s.filter2(c,e,tp,mg)
	local rk=mg:GetSum(Card.GetRank)
	-- 判断额外卡组中是否存在阶级等于目标怪兽阶级总和的「急袭猛禽」超量怪兽，且该怪兽可特殊召唤并有召唤空位
	return c:IsRank(rk) and c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 子函数：判断所选怪兽组中是否至少有一只在场上，并且额外卡组中存在满足条件的超量怪兽
function s.fselect(g,tp,e)
	-- 判断所选怪兽组中是否至少有一只在场上，并且额外卡组中存在满足条件的超量怪兽
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 效果目标选择：获取满足条件的怪兽组，检查是否满足子函数条件，若满足则选择目标怪兽组并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的怪兽组（场上或墓地的「急袭猛禽」超量怪兽）
	local rg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	if chk==0 then return rg:CheckSubGroup(s.fselect,2,99,tp,e) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,99,tp,e)
	-- 设置当前效果的目标怪兽组
	Duel.SetTargetCard(sg)
	-- 设置操作信息：准备特殊召唤1只额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：准备将目标怪兽组中在墓地的怪兽送入墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE),1,0,0)
end
-- 叠放过滤函数：筛选可叠放的怪兽（可叠放、未被效果免疫）
function s.ovfilter(c,e)
	return c:IsCanOverlay() and not c:IsImmuneToEffect(e)
end
-- 效果发动处理：获取目标怪兽组，选择额外卡组中的超量怪兽进行特殊召唤，并将目标怪兽叠放至召唤的怪兽上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中与效果相关的怪兽组
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()<2 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的超量怪兽
	local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tg)
	local sc=sg:GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local og=tg:Filter(s.ovfilter,nil,e)
		-- 遍历目标怪兽组中可叠放的怪兽
		for tc in aux.Next(og) do
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将目标怪兽的叠放卡叠放到召唤的怪兽上
				Duel.Overlay(sc,mg)
			end
			-- 将目标怪兽叠放到召唤的怪兽上
			Duel.Overlay(sc,Group.FromCards(tc))
		end
	end
end
