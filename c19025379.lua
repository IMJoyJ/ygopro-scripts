--ロード・オブ・ザ・レッド
-- 效果：
-- 「真红眼转生」降临。
-- ①：1回合1次，自己或者对方把「真红王」以外的魔法·陷阱·怪兽的效果发动时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：1回合1次，自己或者对方把「真红王」以外的魔法·陷阱·怪兽的效果发动时，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c19025379.initial_effect(c)
	-- 在卡片关联代码列表中添加「真红眼转生」的卡片密码，表示此卡是与「真红眼转生」相关的卡
	aux.AddCodeList(c,45410988)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己或者对方把「真红王」以外的魔法·陷阱·怪兽的效果发动时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19025379,0))  --"选择一张怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c19025379.descon)
	e1:SetTarget(c19025379.destg1)
	e1:SetOperation(c19025379.desop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(19025379,1))  --"选择一张魔法·陷阱破坏"
	e2:SetTarget(c19025379.destg2)
	e2:SetOperation(c19025379.desop2)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：除「真红王」以外的效果发动时，且自身不在战斗破坏确定状态下
function c19025379.descon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(19025379) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 设置效果①发动的靶向信息：以场上1只怪兽为对象，设置破坏的操作信息
function c19025379.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 若为检测模式，检查场上是否存在至少1只怪兽作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给对方玩家提示：展示此卡发动的效果描述（选择一张怪兽破坏）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上的怪兽中选择1只作为效果的对象并将其设定为当前效果的连锁对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果分类为破坏所选目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤条件：场上的魔法·陷阱卡
function c19025379.desfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果②发动的靶向信息：以场上1张魔法·陷阱卡为对象，设置破坏的操作信息
function c19025379.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c19025379.desfilter2(chkc) end
	-- 若为检测模式，检查场上是否存在至少1张魔法或陷阱卡作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(c19025379.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给对方玩家提示：展示此卡发动的效果描述（选择一张魔法·陷阱破坏）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上的魔法·陷阱卡中选择1张作为效果的对象并将其设定为当前效果的连锁对象
	local g=Duel.SelectTarget(tp,c19025379.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果分类为破坏所选目标魔陷卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①处理：若作为对象的卡片仍在场上且为怪兽，则将其破坏
function c19025379.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为当前效果连锁对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 通过效果破坏该目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②处理：若作为对象的卡片仍在场上，则将其破坏
function c19025379.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为当前效果连锁对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果破坏该目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
