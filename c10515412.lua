--ライトストーム・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以最多有自己墓地的通常怪兽数量＋1张的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在自己场上没有通常怪兽存在的场合不能发动。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以最多有自己墓地的通常怪兽数量＋1张的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在自己场上没有通常怪兽存在的场合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 破坏效果的发动处理函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己墓地通常怪兽数量并加1作为最多可破坏的魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)+1
	if chkc then return chkc:IsOnField() end
	-- 检查是否场上存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上最多ct张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息，准备破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组中的卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 盖放效果的发动条件函数
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT+REASON_BATTLE)~=0
end
-- 盖放效果的过滤函数
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的目标选择函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查是否墓地存在可盖放的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	-- 选择墓地一张魔法·陷阱卡作为盖放对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，准备将卡盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 盖放效果的处理函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且可盖放
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)~=0 then
		-- 盖放的卡不能发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.actcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否场上存在通常怪兽的过滤函数
function s.actfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsFaceup()
end
-- 盖放效果发动条件函数
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 若场上没有通常怪兽则不能发动
		and not Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
