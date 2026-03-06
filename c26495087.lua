--ヴァンパイア・レディ
-- 效果：
-- 每当这张卡对对方造成战斗伤害时，宣言1个卡的种类（怪兽·魔法·陷阱），对方从其卡组中选择1张此种类的卡送去墓地。
function c26495087.initial_effect(c)
	-- 创建一个诱发必发效果，当此卡对对方造成战斗伤害时发动
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
-- 效果发动的条件：造成战斗伤害的玩家不是效果持有者
function c26495087.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置效果的目标处理：让对方选择并送去墓地一张指定种类的卡
function c26495087.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示效果持有者选择卡的种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让效果持有者宣言一个卡的种类（怪兽·魔法·陷阱）
	local op=Duel.AnnounceType(tp)
	e:SetLabel(op)
	-- 设置连锁操作信息：对方从卡组选择1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤函数：检查卡片是否属于指定类型且可以送去墓地
function c26495087.tgfilter(c,ty)
	return c:IsType(ty) and c:IsAbleToGrave()
end
-- 效果的处理：根据宣言的种类选择对方卡组中对应类型的卡送去墓地
function c26495087.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	-- 提示对方选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 若宣言为怪兽种类，则选择对方卡组中1张怪兽卡送去墓地
	if e:GetLabel()==0 then g=Duel.SelectMatchingCard(1-tp,c26495087.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	-- 若宣言为魔法种类，则选择对方卡组中1张魔法卡送去墓地
	elseif e:GetLabel()==1 then g=Duel.SelectMatchingCard(1-tp,c26495087.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 若宣言为陷阱种类，则选择对方卡组中1张陷阱卡送去墓地
	else g=Duel.SelectMatchingCard(1-tp,c26495087.tgfilter,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP) end
	if g:GetCount()~=0 then
		-- 将符合条件的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
