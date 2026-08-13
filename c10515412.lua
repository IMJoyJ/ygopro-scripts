--ライトストーム・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以最多有自己墓地的通常怪兽数量＋1张的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
-- ②：这张卡被战斗·效果破坏的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在自己场上没有通常怪兽存在的场合不能发动。
local s,id,o=GetID()
-- 注册同调召唤素材条件（调整+调整以外怪兽1只以上）以及①②两个效果的触发定义：①特殊召唤成功时破坏场上魔法·陷阱卡；②被战斗/效果破坏时从自己墓地盖放魔法·陷阱卡并附加不能发动限制。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 『这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合，以最多有自己墓地的通常怪兽数量＋1张的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。』
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 『这个卡名的①②的效果1回合各能使用1次。②：这张卡被战斗·效果破坏的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在自己场上没有通常怪兽存在的场合不能发动。』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
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
-- ①效果的目标选择：计算可选对象上限（自己墓地通常怪兽数量+1），确认场上有可破坏的魔法·陷阱卡后，选择1~上限张双方场上的魔法·陷阱卡作为对象，并设置破坏处理信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己墓地通常怪兽的数量并加1，作为①效果可选对象的数量上限。
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)+1
	if chkc then return chkc:IsOnField() end
	-- 效果发动时检查双方场上是否存在至少1张可作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 向玩家显示『请选择要破坏的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1~ct张魔法·陷阱卡作为①效果的对象（同时登记为连锁对象）。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置连锁的操作信息：将选择的对象作为将被破坏的卡，数量为g:GetCount()，用于破坏相关检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的结算：从连锁信息中取得对象卡，过滤掉已不被效果关联的卡，将剩余卡全部以效果原因破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象卡组，即①效果发动时选择的目标。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果原因破坏过滤后的对象卡。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被战斗或效果破坏时（破坏原因包含战斗或效果）才能发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义②效果可选择的对象：自己墓地的魔法·陷阱卡且能够盖放（IsSSetable）。
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的目标选择：从自己墓地选择1张可以盖放的魔法·陷阱卡作为对象，并设置从墓地离开的连锁信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 效果发动时检查自己墓地是否存在至少1张可以盖放的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示『请选择要盖放的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张可以盖放的魔法·陷阱卡作为②效果的对象（同时登记为连锁对象）。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息：对象卡将从墓地离开（CATEGORY_LEAVE_GRAVE），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的结算：若对象卡仍与效果相关且不受王家长眠之谷影响，则将其盖放到自己场上；成功后为该盖放卡附加『自己场上没有通常怪兽存在时不能发动』的限制效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果相关、不受王家长眠之谷影响，并尝试将其盖放到自己场上（Duel.SSet成功才继续）。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)~=0 then
		-- 对应效果原文：『这个效果盖放的卡在自己场上没有通常怪兽存在的场合不能发动。』
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「光辉暴风龙」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.actcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义『通常怪兽』的判定条件：表侧表示的通常怪兽，用于检查自己场上是否存在通常怪兽。
function s.actfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsFaceup()
end
-- 作为『不能发动』限制的适用条件：当该盖放卡自身不处于效果有效状态且自己场上不存在表侧通常怪兽时，禁止此卡发动效果。
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
		-- 检查自己场上是否不存在表侧通常怪兽（不存在时返回true，满足不能发动条件）。
		and not Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end
