--ЯRUM－レイド・ラプターズ・フォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段以及对方战斗阶段，以包含场上的怪兽的自己的场上·墓地的「急袭猛禽」超量怪兽2只以上为对象才能发动。把持有和那2只以上的怪兽的阶级合计相同阶级的1只「急袭猛禽」超量怪兽当作超量召唤从额外卡组特殊召唤，把作为对象的怪兽作为那超量素材（作为对象的怪兽持有超量素材的场合，那些也全部作为超量素材）。
local s,id,o=GetID()
-- 创建并注册这张卡的发动效果e1，将该效果设为魔法卡发动、取对象、自由时点发动，并附加1回合1次誓约次数限制，同时指定其发动条件、发动时目标处理和效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张；①：自己·对方的主要阶段以及对方战斗阶段，以包含场上的怪兽的自己的场上·墓地的「急袭猛禽」超量怪兽2只以上为对象才能发动。把持有和那2只以上的怪兽的阶级合计相同阶级的1只「急袭猛禽」超量怪兽当作超量召唤从额外卡组特殊召唤，把作为对象的怪兽作为那超量素材（作为对象的怪兽持有超量素材的场合，那些也全部作为超量素材）。
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
-- 效果的发动条件：只能在己方主要阶段1/2或对方战斗阶段内发动，用于匹配“自己·对方的主要阶段以及对方战斗阶段”的发动时机。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，或者当前为对方回合且阶段处于战斗阶段开始到战斗阶段结束之间（即对方战斗阶段）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 or Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 筛选可作为对象的「急袭猛禽」超量怪兽：阶级大于0且表侧表示（场上表侧或墓地表侧），属于0xba系列，能成为效果对象且未被禁止宣言。
function s.filter1(c,e)
	return c:GetRank()>0 and c:IsFaceup() and c:IsSetCard(0xba) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
-- 从额外卡组筛选符合条件的「急袭猛禽」超量怪兽：其阶级等于所选对象怪兽的阶级合计，属于0xba系列，能够以超量召唤方式特殊召唤，并且己方额外怪兽区域有空位。
function s.filter2(c,e,tp,mg)
	local rk=mg:GetSum(Card.GetRank)
	-- 判断额外卡组的候选超量怪兽阶级是否等于对象组的阶级合计、是否属于「急袭猛禽」系列、是否能被超量召唤，以及是否有可用额外怪兽区。
	return c:IsRank(rk) and c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 选择对象子组的合法性判定：所选对象组中必须至少包含1只场上的怪兽，并且额外卡组中存在与该组阶级合计对应的可特殊召唤的「急袭猛禽」超量怪兽。
function s.fselect(g,tp,e)
	-- 所选的怪兽组中至少有一张位于主要怪兽区（即包含场上的怪兽），同时额外卡组存在满足filter2条件的可特殊召唤目标。
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 效果发动时的目标处理：获取所有可作为对象的本方场上·墓地的「急袭猛禽」超量怪兽，检查能否选出2只以上且满足“包含场上怪兽且有对应额外目标”的子组，然后提示玩家选择目标，将所选目标设为效果对象，并登记特殊召唤及墓地卡离场等操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 取得本方场上（主要怪兽区）和墓地中所有满足filter1条件的「急袭猛禽」超量怪兽，作为可选对象集合。
	local rg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	if chk==0 then return rg:CheckSubGroup(s.fselect,2,99,tp,e) end
	-- 向操作者显示“请选择效果的对象”的选择提示，使后续选择框显示对应文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,99,tp,e)
	-- 将玩家选择的目标怪兽组设置为当前连锁的效果对象，使这些卡在效果处理时与效果关联并可被检索。
	Duel.SetTargetCard(sg)
	-- 登记本次操作信息：效果将进行特殊召唤，从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记本次操作信息：选择的目标中若有墓地怪兽，这些怪兽会因作为超量素材而离开墓地，因此标记CATEGORY_LEAVE_GRAVE。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE),1,0,0)
end
-- 筛选可作为超量素材且不免疫当前效果的对象怪兽，用于效果处理时排除无法叠放或不受影响的卡。
function s.ovfilter(c,e)
	return c:IsCanOverlay() and not c:IsImmuneToEffect(e)
end
-- 效果处理：取得发动时选择的目标，若目标少于2张则终止；从额外卡组选择1只符合条件的「急袭猛禽」超量怪兽，以超量召唤方式特殊召唤；成功后把对象怪兽及其持有的全部超量素材叠放在该超量怪兽下方。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得与当前连锁相关的目标怪兽组，即发动时被设为对象的那些「急袭猛禽」超量怪兽。
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()<2 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示，用于选择额外卡组中要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter2条件的「急袭猛禽」超量怪兽，filter2以目标组tg作为参数来计算阶级合计。
	local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tg)
	local sc=sg:GetFirst()
	-- 将选择的超量怪兽以超量召唤方式（SUMMON_TYPE_XYZ）特殊召唤到己方场上，并确认特殊召唤是否成功（返回数量不为0）。
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local og=tg:Filter(s.ovfilter,nil,e)
		-- 遍历所有通过ovfilter过滤、可用于叠放的对象怪兽，逐一处理其作为超量素材的叠放。
		for tc in aux.Next(og) do
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 若对象怪兽自身持有超量素材，则将这些超量素材整体叠放到特殊召唤出的超量怪兽下方。
				Duel.Overlay(sc,mg)
			end
			-- 将对象怪兽本身作为超量素材叠放到特殊召唤出的超量怪兽下方，完成“把作为对象的怪兽作为那超量素材”的处理。
			Duel.Overlay(sc,Group.FromCards(tc))
		end
	end
end
