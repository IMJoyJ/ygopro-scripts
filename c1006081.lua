--ジャンク・チェンジャー
-- 效果：
-- 「废品变更者」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，可以以场上1只「废品」怪兽为对象从以下效果选择1个发动。
-- ●作为对象的怪兽的等级上升1星。
-- ●作为对象的怪兽的等级下降1星。
function c1006081.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，可以以场上1只「废品」怪兽为对象从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1006081,0))  --"等级变更"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1006081)
	e1:SetTarget(c1006081.target)
	e1:SetOperation(c1006081.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 作为对象的怪兽的过滤条件函数：场上表侧表示、等级大于0且属于「废品」系列的怪兽
function c1006081.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x43)
end
-- 效果①的发动效果目标（Target）处理：选择场上1只「废品」怪兽作为对象，并让玩家选择对其等级上升或下降1星
function c1006081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1006081.filter(chkc) end
	-- 在发动时点检查场上是否存在至少1只表侧表示且等级大于0的「废品」怪兽
	if chk==0 then return Duel.IsExistingTarget(c1006081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择表侧表示卡片的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家在场上选择1只满足过滤条件的「废品」怪兽作为对象
	local g=Duel.SelectTarget(tp,c1006081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local op=0
	-- 给玩家发送选择要发动的效果的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if g:GetFirst():IsLevel(1) then
		-- 若选中的怪兽等级为1，玩家只能选择使其等级上升1星
		op=Duel.SelectOption(tp,aux.Stringid(1006081,1))  --"等级上升1星"
	else
		-- 若选中的怪兽等级大于1，让玩家选择是等级上升1星还是下降1星
		op=Duel.SelectOption(tp,aux.Stringid(1006081,1),aux.Stringid(1006081,2))  --"等级上升1星/等级下降1星"
	end
	e:SetLabel(op)
end
-- 效果①的效果处理（Operation）函数：对被选为对象的怪兽适用所选的等级上升或下降1星的效果
function c1006081.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ●作为对象的怪兽的等级上升1星。 / ●作为对象的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		tc:RegisterEffect(e1)
	end
end
