--ヴァンパイア・レディ
-- 效果：
-- 每当这张卡对对方造成战斗伤害时，宣言1个卡的种类（怪兽·魔法·陷阱），对方从其卡组中选择1张此种类的卡送去墓地。
function c26495087.initial_effect(c)
	-- 每当这张卡对对方造成战斗伤害时，宣言1个卡的种类（怪兽·魔法·陷阱），对方从其卡组中选择1张此种类的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26495087,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c26495087.tgcon)
	e1:SetTarget(c26495087.tgtg)
	e1:SetOperation(c26495087.tgop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：受到战斗伤害的玩家是对方，即造成战斗伤害的对象不是这张卡的控制者。
function c26495087.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时的目标设定：无条件可发动，宣言一个卡的种类（怪兽·魔法·陷阱），将宣言结果存入效果标签，并设置操作信息为把对方卡组中的1张卡送去墓地。
function c26495087.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 发动时给当前玩家显示‘请选择一个种类’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让当前玩家宣言一个卡片种类（怪兽·魔法·陷阱），返回值作为选择结果。
	local op=Duel.AnnounceType(tp)
	e:SetLabel(op)
	-- 设置本次效果的操作信息：将对方（1-tp）卡组中的1张卡送去墓地，用于连锁检测和效果信息查询。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 选择送去墓地的卡的过滤函数：必须是宣言的种类对应的卡片，并且可以被送去墓地。
function c26495087.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- 效果处理时的操作：根据宣言的种类，由对方玩家从其卡组中选择1张相应种类的卡（怪兽/魔法/陷阱）。
function c26495087.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 效果处理时向对方玩家显示‘请选择要送去墓地的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 如果宣言的种类是怪兽（标签为0），让对方从自身卡组选择1张怪兽卡。
	if e:GetLabel()==0 then g=Duel.SelectMatchingCard(1-tp,c26495087.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	-- 如果宣言的种类是魔法（标签为1），让对方从自身卡组选择1张魔法卡。
	elseif e:GetLabel()==1 then g=Duel.SelectMatchingCard(1-tp,c26495087.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 否则宣言的种类是陷阱，让对方从自身卡组选择1张陷阱卡。
	else g=Duel.SelectMatchingCard(1-tp,c26495087.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP) end
	if g:GetCount()~=0 then
		-- 将选择的那1张卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
