--夜霧のスナイパー
-- 效果：
-- 宣言1个怪兽卡名。对方把宣言怪兽召唤·特殊召唤·反转的场合，宣言怪兽和这张卡从游戏中除外。
function c8323633.initial_effect(c)
	-- 宣言1个怪兽卡名。对方把宣言怪兽召唤·特殊召唤·反转的场合，宣言怪兽和这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c8323633.operation)
	c:RegisterEffect(e1)
end
-- 魔法·陷阱卡发动时的效果处理：让玩家宣言一个怪兽卡名，并在魔法与陷阱区域注册当该怪兽被召唤、特殊召唤、反转时触发的除外效果。
function c8323633.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给发动效果的玩家发送“请宣言一个卡名”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让发动效果的玩家宣言一个怪兽卡名。
	local ac=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE)
	c:SetHint(CHINT_CARD,ac)
	-- 对方把宣言怪兽召唤·特殊召唤·反转的场合，宣言怪兽和这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8323633,0))  --"除外"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c8323633.rmcon)
	e1:SetTarget(c8323633.rmtg)
	e1:SetOperation(c8323633.rmop)
	e1:SetLabel(ac)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 过滤出场上表侧表示且卡名为宣言卡名的怪兽。
function c8323633.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 触发条件：对方召唤、特殊召唤或反转的怪兽中存在表侧表示的宣言怪兽。
function c8323633.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c8323633.filter,1,nil,e:GetLabel()) and rp==1-tp
end
-- 效果的目标：将触发事件的怪兽组设为效果目标，并设置除外操作的信息（包含宣言怪兽和这张卡）。
function c8323633.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前触发事件的怪兽组设为效果的处理对象。
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c8323633.filter,nil,e:GetLabel())
	g:AddCard(e:GetHandler())
	-- 设置连锁的操作信息，表示此效果的处理包含将目标怪兽和这张卡除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：将场上对应被召唤/特殊召唤/反转的宣言怪兽以及这张卡表侧表示除外。
function c8323633.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(c8323633.filter,nil,e:GetLabel()):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 因效果将目标怪兽和这张卡以表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
