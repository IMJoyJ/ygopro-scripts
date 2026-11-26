--ジュラック・スティゴ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
-- ②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：关联本卡卡名，并注册①效果（起动破坏己方场上1张卡、从卡组把恐龙族怪兽送墓并可选特召「朱罗纪」怪兽）与②效果（被战斗破坏时使场上1张表侧卡回手卡）
function s.initial_effect(c)
	-- 在卡上记述本卡卡名「朱罗纪剑龙」的卡号，用于相关效果的卡名检索与识别
	aux.AddCodeList(c,id)
	-- 这个卡名的①的效果1回合只能使用1次。 ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏并送去墓地"
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_DECK_SPSUMMON)
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
-- 筛选条件：检查卡片是否为等级1以上、可送去墓地的恐龙族怪兽
function s.tgfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
-- 筛选条件：检查卡片是否为「朱罗纪剑龙」以外、等级1以上的「朱罗纪」怪兽且能无视召唤条件特殊召唤
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x22) and c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 子组校验函数：检查所选怪兽组的等级合计是否等于目标等级
function s.gcheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- ①效果的发动检测与连锁信息设置：检查己方场上是否有卡且卡组有可送墓的恐龙族怪兽，并登记破坏和送去墓地的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上的全部卡片组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil,e,tp)
	-- 发动条件检查：确认己方场上有卡，且己方卡组存在至少1只符合条件的恐龙族怪兽
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记连锁的破坏操作信息，预计破坏己方场上1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记连锁的送去墓地操作信息，预计从己方卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理流程：破坏己方场上1张卡，从卡组将1只恐龙族怪兽送去墓地，可选从手卡·卡组无视召唤条件特召等级合计相同的「朱罗纪」怪兽，并在之后施加本回合只能特召恐龙族的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从己方场上选择1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 高亮显示被选定破坏的卡片
	Duel.HintSelection(g)
	-- 以效果破坏所选卡片，并判断是否破坏成功
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取己方主要怪兽区的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 向己方提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让己方从己方卡组选择1只满足条件的恐龙族怪兽
		local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local gc=sg:GetFirst()
		-- 将所选恐龙族怪兽以效果送去墓地，并确认其成功进入墓地且己方场上仍有怪兽区空位
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and ft>0 then
			local lv=gc:GetLevel()
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 获取己方手卡与卡组中满足特殊召唤条件的「朱罗纪」怪兽集合
			local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
			-- 检查是否存在等级合计等于目标等级的可特殊召唤怪兽组合，并询问己方是否进行特殊召唤
			if tg:CheckSubGroup(s.gcheck,1,ft,lv) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 向己方提示选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local ssg=tg:SelectSubGroup(tp,s.gcheck,false,1,ft,lv)
				if ssg then
					-- 中断效果处理，使后续的特殊召唤与前面的破坏送墓视为不同时处理
					Duel.BreakEffect()
					-- 将所选「朱罗纪」怪兽以表侧表示、无视召唤条件特殊召唤到己方场上
					Duel.SpecialSummon(ssg,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
	-- 这个回合，自己不是恐龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续到回合结束时的特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤函数：禁止特殊召唤非恐龙族的怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_DINOSAUR)
end
-- ②效果的发动检测与连锁信息设置：确认双方场上存在表侧表示且可回到手卡的卡，并登记返回手卡操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认双方场上存在至少1张表侧表示且能回到手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 登记连锁的返回手卡操作信息，预计使场上1张卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- ②效果的处理流程：从双方场上选1张表侧表示的卡使其回到持有者手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方提示选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让己方从双方场上选择1张表侧表示且可回到手卡的卡
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 高亮显示被选定返回手卡的卡片
		Duel.HintSelection(g)
		-- 以效果将所选卡片返回原持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
