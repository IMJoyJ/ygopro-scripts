--忘却の海底神殿
-- 效果：
-- 只要这张卡在场上存在，这张卡的卡名当作「海」使用。1回合1次，可以选择自己场上表侧表示存在的1只4星以下的鱼族·海龙族·水族怪兽从游戏中除外。这个效果除外的怪兽在自己的结束阶段时在场上特殊召唤。
function c43889633.initial_effect(c)
	-- 将记载的「海」（卡号22702055）加入代码列表，便于后续卡名视为「海」的判定。
	aux.AddCodeList(c,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「1回合1次，可以选择自己场上表侧表示存在的1只4星以下的鱼族·海龙族·水族怪兽从游戏中除外。」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43889633,1))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c43889633.target)
	e2:SetOperation(c43889633.operation)
	c:RegisterEffect(e2)
	-- 注册“这张卡的卡名当作「海」使用”的永续效果，使这张卡在魔陷区表侧表示时卡名视为「海」。
	aux.EnableChangeCode(c,22702055)
	-- 「这个效果除外的怪兽在自己的结束阶段时在场上特殊召唤。」
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43889633,2))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c43889633.spcon)
	e3:SetTarget(c43889633.sptg)
	e3:SetOperation(c43889633.spop)
	c:RegisterEffect(e3)
end
-- 定义可选对象的过滤条件：表侧表示、4星以下、种族为鱼族·海龙族·水族之一，且能够被除外。
function c43889633.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToRemove()
end
-- 发动时的取对象处理：检查是否有符合条件的对象，若满足则提示玩家从自己场上选择1只符合条件的表侧表示怪兽作为对象，并设置除外相关的操作信息。
function c43889633.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43889633.filter(chkc) end
	-- 在发动时点检查自己场上是否存在至少1只满足条件的表侧表示怪兽可以作为对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43889633.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择提示，要求从自己场上选择1只要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只符合条件的怪兽，并将该卡设置为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c43889633.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本次连锁的操作信息：将把所选择的怪兽以效果除外，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理时：取得对象卡，若对象卡仍然与效果关联且仍为对应种族，则将其表侧除外；除外成功后，记录该卡的FieldID标记，以便结束阶段识别并特殊召唤。
function c43889633.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联、种族是否仍符合，并执行表侧除外；若除外成功且卡确实位于除外区，才继续记录标记。
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(43889634,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
-- 定义过滤函数：检查除外区的怪兽是否带有本效果赋予的标记，且标记值等于当前神殿的FieldID，用于确定是由本卡效果除外的怪兽。
function c43889633.spfilter(c,fid)
	return c:GetFlagEffect(43889634)~=0 and c:GetFlagEffectLabel(43889634)==fid
end
-- 结束阶段特殊召唤效果的发动条件：当前是这张卡控制者的结束阶段，且除外区存在由本卡效果除外的怪兽，满足时效果自动发动。
function c43889633.spcon(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	-- 判定当前回合玩家是否为本卡控制者，以及除外区是否存在带对应FieldID标记的怪兽；两者同时满足时发动条件成立。
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c43889633.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,fid)
end
-- 特殊召唤效果的目标处理：发动条件已满足，检索除外区中所有带对应标记的怪兽，并设置特殊召唤的操作信息。
function c43889633.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local fid=e:GetHandler():GetFieldID()
	-- 获取除外区中所有带对应FieldID标记的怪兽（即由本卡效果除外的怪兽），准备特殊召唤。
	local tg=Duel.GetMatchingGroup(c43889633.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,fid)
	-- 设置本次连锁的操作信息：将把检索到的怪兽进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end
-- 特殊召唤效果处理：从除外区取回带对应FieldID标记的怪兽，若存在则将其以表侧表示特殊召唤到控制者场上。
function c43889633.spop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	-- 获取除外区中所有带对应FieldID标记的怪兽，作为本次特殊召唤的对象。
	local tg=Duel.GetMatchingGroup(c43889633.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,fid)
	if #tg>0 then
		-- 将上述怪兽全部以表侧表示特殊召唤到控制者场上，不进行召唤条件/苏生限制的检查（因为是效果除外的回归）。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
