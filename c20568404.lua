--ジュラック・スティゴ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
-- ②：这张卡被战斗破坏时才能发动。场上1张表侧表示卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 记录卡名列表中包含自身卡名
	aux.AddCodeList(c,id)
	-- ①：自己主要阶段才能发动。自己场上1张卡破坏，从卡组把1只恐龙族怪兽送去墓地。那之后，可以直到等级合计变成和从卡组送去墓地的怪兽相同为止从手卡·卡组把「朱罗纪剑龙」以外的「朱罗纪」怪兽无视召唤条件特殊召唤。这个回合，自己不是恐龙族怪兽不能特殊召唤。
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
-- 过滤卡组中等级1以上且可送去墓地的恐龙族怪兽
function s.tgfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
-- 过滤手卡·卡组中「朱罗纪剑龙」以外等级1以上且可特殊召唤的「朱罗纪」怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x22) and c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 检查怪兽组的等级合计是否等于目标等级
function s.gcheck(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 效果①的目标设置：确认场上存在卡且卡组存在恐龙族怪兽，并声明破坏与送去墓地操作
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有的卡片组
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil,e,tp)
	-- 检查自己场上是否存在卡且卡组是否存在符合条件的恐龙族怪兽
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：破坏自己场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的操作处理：破坏自己场上的卡，从卡组将恐龙族怪兽送去墓地，并可特殊召唤等级合计相同的「朱罗纪」怪兽，随后施加特殊召唤种族限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 显示选为破坏目标的卡片动画
	Duel.HintSelection(g)
	-- 成功破坏目标卡片时执行后续处理
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 获取自身主要怪兽区域空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只恐龙族怪兽
		local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local gc=sg:GetFirst()
		-- 确认怪兽成功送去墓地且场上有空位时执行后续处理
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and ft>0 then
			local lv=gc:GetLevel()
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 获取手卡·卡组中所有符合特殊召唤条件的「朱罗纪」怪兽
			local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
			-- 检查是否存在等级合计等于送墓怪兽等级的怪兽子集，并由玩家选择是否特殊召唤
			if tg:CheckSubGroup(s.gcheck,1,ft,lv) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 提示选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local ssg=tg:SelectSubGroup(tp,s.gcheck,false,1,ft,lv)
				if ssg then
					-- 中断当前效果处理
					Duel.BreakEffect()
					-- 将选择的怪兽表侧表示无视召唤条件特殊召唤
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
	-- 为玩家注册回合结束前不能特殊召唤非恐龙族怪兽的限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤非恐龙族怪兽（用于特殊召唤限制）
function s.splimit(e,c)
	return not c:IsRace(RACE_DINOSAUR)
end
-- 效果②的目标设置：确认场上存在表侧表示卡片并声明回到手卡操作
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以回到手卡的表侧表示卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息：场上1张卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- 效果②的操作处理：选择场上1张表侧表示卡回到手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张可以回到手卡的表侧表示卡
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选为返回手牌目标的卡片动画
		Duel.HintSelection(g)
		-- 将选择的卡送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
