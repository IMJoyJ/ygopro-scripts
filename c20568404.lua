--ジュラック・スティゴ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
-- ②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
local s,id,o=GetID()
-- 给这张卡注册两个效果：①是起动效果，可在自己主要阶段破坏自己场上1张卡、从卡组送墓1只恐龙族怪兽，之后可选特殊召唤「朱罗纪」怪兽并附加自肃；②是战斗破坏时的诱发效果，可将场上1张表侧表示卡弹回手牌。
function s.initial_effect(c)
	-- 将自身卡号记录为这张卡效果文本中记载的卡名（「朱罗纪剑龙」），以便相关判定中识别并排除这张卡。
	aux.AddCodeList(c,id)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏并送去墓地"
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 从卡组选择“等级1以上、恐龙族、可以送去墓地”的怪兽作为送墓候选的过滤条件。
function s.tgfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
-- 从手卡·卡组选择可特殊召唤候选：不是「朱罗纪剑龙」、属于「朱罗纪」字段、等级1以上、怪兽，且能够无视召唤条件特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x22) and c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判定所选一组怪兽的等级合计是否等于指定等级（即之前送去墓地的怪兽的等级）。
function s.gcheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- ①效果的发动条件与操作信息设定：自己场上需要有可破坏的卡且卡组有可送墓的恐龙族怪兽；发动时预设置破坏自己场上1张卡、从卡组送墓1只恐龙族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己场上全部卡，用于确认是否存在可破坏的对象以及设置破坏操作信息。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil,e,tp)
	-- 发动时合法性检查：自己场上存在至少1张卡，且卡组存在符合条件的恐龙族怪兽。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置“破坏自己场上1张卡”的操作信息，将场上所有自军卡作为可能破坏对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置“从自己卡组把1只恐龙族怪兽送去墓地”的操作信息，对象暂不确定，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：先选择并破坏自己场上1张卡；若成功，从卡组选1只恐龙族怪兽送去墓地；随后若送墓成功且有空位，可自愿从手卡·卡组选等级合计相同的「朱罗纪」怪兽（不含自身）无视召唤条件特殊召唤；最后给己方附加本回合只能特殊召唤恐龙族怪兽的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示操作者选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果处理时选择自己场上1张卡进行破坏（不取对象）。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将被选择的卡显示为对象动画，并记录为与当前效果关联的卡。
	Duel.HintSelection(g)
	-- 实际执行破坏，只有破坏了至少1张卡才继续后续送墓和特殊召唤处理。
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取自己主怪兽区可用空格数量，作为这次特殊召唤可召唤数量的上限。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 提示操作者选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只满足条件的恐龙族怪兽送去墓地（效果处理时选择，不取对象）。
		local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local gc=sg:GetFirst()
		-- 确认送墓成功且怪兽仍在墓地，并且主怪兽区有空格，才接下来处理特殊召唤部分。
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and ft>0 then
			local lv=gc:GetLevel()
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 从手牌·卡组中筛选出所有可被特殊召唤的「朱罗纪」怪兽（不含「朱罗纪剑龙」）作为候选组。
			local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
			-- 检查候选组中是否存在等级合计等于送墓怪兽等级的一组（1到ft张），并让玩家选择是否发动特殊召唤。
			if tg:CheckSubGroup(s.gcheck,1,ft,lv) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 提示操作者选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local ssg=tg:SelectSubGroup(tp,s.gcheck,false,1,ft,lv)
				if ssg:GetCount()>0 then
					-- 中断当前效果链，使后续特殊召唤作为不同时处理，以免错失时点。
					Duel.BreakEffect()
					-- 将选择的怪兽无视召唤条件、以正面表示特殊召唤到己方怪兽区。
					Duel.SpecialSummon(ssg,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
	-- 这个回合，自己不是恐龙族怪兽不能特殊召唤。②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“己方本回合不能特殊召唤非恐龙族怪兽”的自肃效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制逻辑：不是恐龙族怪兽的卡不能进行特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_DINOSAUR)
end
-- ②效果的发动条件和操作信息：双方场上存在表侧表示且能加入手卡的卡才能发动；设置将场上1张表侧表示卡回手的效果信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动时检查：场上（双方）存在至少1张表侧表示且可以加入手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置“场上1张表侧表示卡返回手卡”的操作信息，数量1，位置为场上。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- ②效果处理：选择场上1张表侧表示卡，将其返回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示操作者选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 效果处理时选择场上1张表侧表示且可以加入手卡的卡（不取对象）。
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中动画并记录为与效果关联的卡。
		Duel.HintSelection(g)
		-- 将选中的卡返回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
