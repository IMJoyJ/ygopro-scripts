--落消しのパズロミノ
-- 效果：
-- 等级不同的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽表侧表示特殊召唤的场合，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
-- ②：从自己和对方的场上以相同等级的怪兽各1只为对象才能发动。那些怪兽破坏。
function c84271823.initial_effect(c)
	-- 设置Link召唤手续：等级不同的怪兽2只
	aux.AddLinkProcedure(c,c84271823.mfilter,2,2,c84271823.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽表侧表示特殊召唤的场合，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84271823,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,84271823)
	e1:SetCondition(c84271823.lvcon)
	e1:SetTarget(c84271823.lvtg)
	e1:SetOperation(c84271823.lvop)
	c:RegisterEffect(e1)
	-- ②：从自己和对方的场上以相同等级的怪兽各1只为对象才能发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84271823,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,84271824)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c84271823.destg)
	e2:SetOperation(c84271823.desop)
	c:RegisterEffect(e2)
end
-- Link素材过滤条件：存在等级的怪兽
function c84271823.mfilter(c)
	return c:IsLevelAbove(0)
end
-- Link召唤素材检查：素材怪兽的等级各不相同
function c84271823.lcheck(g,lc)
	return g:GetClassCount(Card.GetLevel)==g:GetCount()
end
-- 特殊召唤怪兽过滤条件：此卡所连接区表侧表示且有等级的怪兽
function c84271823.cfilter(c,lg)
	return c:IsFaceup() and c:IsLevelAbove(0) and lg:IsContains(c)
end
-- ①效果发动条件：此卡所连接区有表侧表示且有等级的怪兽特殊召唤，且不包含自身
function c84271823.lvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(c84271823.cfilter,1,nil,c:GetLinkedGroup())
end
-- ①效果发动准备：宣言1～8的任意等级并保存目标怪兽组
function c84271823.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=eg:Filter(c84271823.cfilter,nil,c:GetLinkedGroup())
	g:KeepAlive()
	local ct={}
	for i=1,8 do
		if not g:IsExists(Card.IsLevel,1,nil,i) then table.insert(ct,i) end
	end
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 由玩家宣言可变更的等级
	local lv=Duel.AnnounceNumber(tp,table.unpack(ct))
	e:SetLabel(lv)
	e:SetLabelObject(g)
end
-- 等级变更过滤条件：表侧表示且当前等级不等于宣言等级的怪兽
function c84271823.efilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(0) and not c:IsLevel(lv)
end
-- ①效果处理：使目标怪兽直到回合结束时变成宣言的等级
function c84271823.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(c84271823.efilter,nil,lv)
	local tc=tg:GetFirst()
	if #g>2 then
		-- 多于2只怪兽特召时提示玩家选择1只作为效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	g:DeleteGroup()
	if tc then
		-- 效果处理：注册等级变更效果，直到回合结束时变为宣言的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 破坏对象过滤条件（己方）：己方场上表侧表示有等级且对方场上存在同等级可作为对象怪兽的怪兽
function c84271823.tgfilter1(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(0)
		-- 检查对方场上是否存在与己方目标怪兽等级相同的可对象怪兽
		and Duel.IsExistingMatchingCard(c84271823.tgfilter2,tp,0,LOCATION_MZONE,1,nil,e,c:GetLevel())
end
-- 破坏对象过滤条件（对方）：对方场上表侧表示且与己方选定怪兽同等级的可作为效果对象的怪兽
function c84271823.tgfilter2(c,e,lv)
	return c:IsFaceup() and c:IsLevelAbove(0) and c:IsLevel(lv) and c:IsCanBeEffectTarget(e)
end
-- ②效果发动准备：选择自己和对方场上相同等级的怪兽各1只作为对象，并设置破坏操作信息
function c84271823.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：自己场上是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c84271823.tgfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择己方要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从己方场上选择1只满足条件的怪兽作为对象
	local g1=Duel.SelectTarget(tp,c84271823.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 提示玩家选择对方要破坏的同等级怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只与己方所选怪兽同等级的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c84271823.tgfilter2,tp,0,LOCATION_MZONE,1,1,nil,e,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 设置连锁操作信息：破坏选中的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②效果处理：将作为对象的2只怪兽破坏
function c84271823.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍关联效果的对象怪兽破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
