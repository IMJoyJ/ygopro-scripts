--A・O・J リーサル・ウェポン
-- 效果：
-- 这张卡战斗破坏光属性怪兽送去墓地时，从自己卡组抽1张卡。这个效果抽到的卡是4星以下的暗属性怪兽的场合，可以把那张卡给对方观看在自己场上特殊召唤。
function c45450218.initial_effect(c)
	-- 这张卡战斗破坏光属性怪兽送去墓地时（此处为辅助判定：在战斗阶段记录与这张卡交战的对方怪兽是否为光属性）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c45450218.checkop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏光属性怪兽送去墓地时，从自己卡组抽1张卡。这个效果抽到的卡是4星以下的暗属性怪兽的场合，可以把那张卡给对方观看在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45450218,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c45450218.condition)
	e2:SetTarget(c45450218.target)
	e2:SetOperation(c45450218.operation)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查当前伤害计算后的战斗对象：若攻击者是本卡则判断攻击目标，否则判断攻击者；若该怪兽为光属性则将e1的标签设为1，否则设为0，作为后续“战斗破坏光属性怪兽”的辅助确认。
function c45450218.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这次战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是本卡自身，则将判定对象改为攻击目标，即与这张卡战斗的对方怪兽。
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc and tc:IsAttribute(ATTRIBUTE_LIGHT) then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 诱发条件判定：这次被战斗破坏送去墓地的怪兽只有1只，且该怪兽在墓地、是被战斗破坏、属性为光、破坏者是这张卡自身，并且之前checkop已记录本次战斗对象为光属性，全部满足时效果才能发动。
function c45450218.condition(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:GetFirst()
	return eg:GetCount()==1 and dg:IsLocation(LOCATION_GRAVE) and dg:IsReason(REASON_BATTLE)
		and dg:IsAttribute(ATTRIBUTE_LIGHT) and dg:GetReasonCard()==e:GetHandler() and e:GetLabelObject():GetLabel()==1
end
-- 效果发动时的目标处理：本效果必定可以发动，登记操作信息后等待处理。
function c45450218.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果包含抽卡操作，向当前玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：先抽1张卡；若抽到了卡且自己场上有空位，则检查抽到的卡是否能作为4星以下暗属性怪兽被特殊召唤以及玩家是否同意；若同意则给对方确认并特殊召唤。
function c45450218.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让自己抽1张卡。
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	-- 如果抽卡没有实际抽到（数量为0），或者自己主要怪兽区没有可用的空格，则无法进行后续特殊召唤，直接结束处理。
	if ct==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得刚才通过抽卡操作实际加入手牌的那张卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsLevelBelow(4) and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否将抽到的这张4星以下暗属性怪兽特殊召唤，若玩家选择是则继续。
		and Duel.SelectYesNo(tp,aux.Stringid(45450218,1)) then  --"是否要特殊召唤？"
		-- 将那张抽到的卡展示给对方玩家，对应效果中的“给对方观看”。
		Duel.ConfirmCards(1-tp,tc)
		-- 将那张卡以表侧攻击/正面表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
