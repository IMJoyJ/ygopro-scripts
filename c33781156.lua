--鉄獣式撃滅兵装“Mouser”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组·额外卡组把「铁兽式击灭兵装“捕鼠猫”」以外的2张「铁兽」卡送去墓地（同名卡最多1张）。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 初始化卡片的脚本：注册连接召唤手续（兽·兽战士族·鸟兽族怪兽2只）以及①②效果；①为连接召唤成功时从卡组·额外卡组送墓2张「铁兽」卡并附加额外召唤限制，②为被送去墓地将场上1只表侧表示怪兽变为里侧守备表示。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：素材为种族是兽族、兽战士族或鸟兽族的怪兽，需要2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤的场合才能发动。从卡组·额外卡组把「铁兽式击灭兵装“捕鼠猫”」以外的2张「铁兽」卡送去墓地（同名卡最多1张）。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：本卡用连接召唤方式特殊召唤成功。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的检索过滤条件：不是本卡同名卡、属于「铁兽」字段、且可以送去墓地的卡。
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x14d) and c:IsAbleToGrave()
end
-- 效果①的发动时机处理：检查卡组·额外卡组是否存在至少2张卡名不同的满足条件的「铁兽」卡，并将本次操作信息设置为从卡组·额外卡组把2张卡送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方卡组·额外卡组中所有满足tgfilter（可送墓的「铁兽」卡且非本卡）的卡。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
	-- 设置操作信息：本连锁将把2张卡从卡组·额外卡组送去墓地，供其他卡效果响应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_EXTRA+LOCATION_DECK)
end
-- 效果①处理：让玩家选择2张卡名不同的「铁兽」卡并送去墓地；随后给己方附加本回合的额外卡组自肃：不能特殊召唤兽/兽战士/鸟兽族以外的额外怪兽。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字，提示玩家选择要送去墓地的「铁兽」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果处理时重新获取满足tgfilter的卡集合。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	-- 判断该集合中是否存在2张卡名互不相同的组合（满足同名卡最多1张）。
	if g:CheckSubGroup(aux.dncheck,2,2) then
		-- 临时设置SelectSubGroup的附加过滤条件为卡名互不相同（dncheck）。
		aux.GCheckAdditional=aux.dncheck
		-- 让玩家从符合条件的卡中选择2张卡名不同的卡。
		local sg=g:SelectSubGroup(tp,aux.TRUE,false,2,2)
		-- 清除步骤id14中临时设置的附加过滤条件。
		aux.GCheckAdditional=nil
		if sg and sg:GetCount()==2 then
			-- 将选中的2张「铁兽」卡以效果原因送入墓地。
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	-- ①后半：这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。②：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册到当前玩家tp，使该效果影响tp（此回合限制tp从额外卡组特殊召唤）。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定函数：如果怪兽在额外卡组且种族不是兽族·兽战士族·鸟兽族，则禁止特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- ②的取对象过滤条件：对象必须表侧表示且可以被变为里侧守备表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②的发动时选择：从双方场上选择1只表侧表示怪兽作为对象，并设置将其改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- ②发动时检查双方怪兽区是否存在1只满足posfilter（表侧且可盖放）的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示怪兽作为效果对象（并建立对象关联）。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将把对象怪兽的表示形式变为里侧守备表示。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理：将对象怪兽变为里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的效果对象（通过SelectTarget选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将对象怪兽的表示形式变更为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
