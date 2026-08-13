--傀儡遊儀－サービスト・パペット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「机关傀儡」超量怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽的控制权直到结束阶段得到。
-- ②：自己场上有「机关傀儡」超量怪兽存在的场合，把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只超量怪兽为对象才能发动。那只怪兽在自己或对方的场上守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册这张卡的两个效果：①作为通常魔法在自由时点发动，取对象夺取对方场上怪兽控制权直到结束阶段；②作为墓地诱发即时效果，满足条件时除外自身并取对象特殊召唤墓地超量怪兽。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以最多有自己场上的「机关傀儡」超量怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"取得对方场上怪兽控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「机关傀儡」超量怪兽存在的场合，把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只超量怪兽为对象才能发动。那只怪兽在自己或对方的场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"在自己或对方场上特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置②效果的发动代价：从墓地除外自身（作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：表侧表示且属于「机关傀儡」字段的超量怪兽，用于统计自己场上机关傀儡超量怪兽数量。
function s.filter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- ①效果的发动时处理：计算可选择对方怪兽的数量上限（取自己场上机关傀儡超量怪兽数与自身怪兽区空位数的最小值），选择1~ct只对方场上可改变控制权的怪兽为对象，并设置改变控制权的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- ct取自己场上表侧「机关傀儡」超量怪兽数量和自己的主要怪兽区可用空格数中的较小值，作为可选择对方怪兽的最大数量。
	local ct=math.min(Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(s.filter,nil),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and Card.IsControlerCanBeChanged(chkc) end
	-- 发动合法性检查：对方场上有可改变控制权的怪兽，并且ct>0（即自己场上有机关傀儡超量怪兽且自己怪兽区有空位）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) and ct>0 end
	-- 向玩家展示选择提示，要求选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1~ct只可改变控制权的怪兽作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置当前连锁的操作信息：将所选对象怪兽的控制权变更纳入处理。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- ①效果处理时：取得本次连锁的对象怪兽，将其控制权直到结束阶段转移给自己。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的所有对象怪兽（与当前连锁关联的目标）。
	local tg=Duel.GetTargetsRelateToChain()
	-- 将对象怪兽的控制权直到结束阶段转移给自己，PHASE_END,1表示在结束阶段归还控制权一次。
	Duel.GetControl(tg,tp,PHASE_END,1)
end
-- 定义过滤条件：自己场上表侧表示且属于「机关傀儡」字段的超量怪兽，用于②效果的发动条件判断。
function s.cfilter(c)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- ②效果的发动条件：自己场上有表侧「机关傀儡」超量怪兽存在，并且这张卡不是本回合被送去墓地（当前回合数与进入墓地的回合数不同），或者因返回墓地的原因进入墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「机关傀儡」超量怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and
	-- 检查这张卡不是本回合被送去墓地（通过比较回合数），或者因REASON_RETURN原因回到墓地，从而满足“这个回合没有送去墓地”的条件。
	Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN)
end
-- 定义选对象过滤条件：对象必须是超量怪兽，并且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标与合法性检查：确认自己或对方的主要怪兽区至少有一个空位，并从双方墓地选择1只符合条件的超量怪兽作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 合法性检查：自己或对方的主要怪兽区至少有一个空位可供特殊召唤。
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		-- 并且双方墓地存在至少1只满足s.spfilter的超量怪兽可以被选为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1只满足条件的超量怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：将特殊召唤该对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若仍与效果相关，则让玩家选择在自己或对方场上表侧守备表示特殊召唤，并根据选择执行召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽（本效果选择的那只超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 判断自己场上是否有可用的主要怪兽区空格，并且对象怪兽能够以表侧守备表示特殊召唤到自己场上。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 判断对方场上是否有可用的主要怪兽区空格，并且对象怪兽能够以表侧守备表示特殊召唤到对方场上。
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		-- 使用辅助函数让玩家在“自己场上特殊召唤”和“对方场上特殊召唤”两个有效选项中做出选择。
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2)},  --"在自己场上特殊召唤"
			{b2,aux.Stringid(id,3)})  --"在对方场上特殊召唤"
		if op==1 then
			-- 在自己场上以表侧守备表示特殊召唤对象怪兽。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 在对方场上以表侧守备表示特殊召唤对象怪兽。
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
