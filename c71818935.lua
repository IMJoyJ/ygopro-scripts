--閉ザサレシ天ノ月
-- 效果：
-- 效果怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这张卡所连接区1只对方的表侧表示怪兽为对象才能发动。这个回合，自己用自己场上的这张卡为素材把连接5怪兽连接召唤的场合，作为对象的对方怪兽也能作为连接素材。
local s,id,o=GetID()
-- 注册卡片效果与连接召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：效果怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- ①：以这张卡所连接区1只对方的表侧表示怪兽为对象才能发动。这个回合，自己用自己场上的这张卡为素材把连接5怪兽连接召唤的场合，作为对象的对方怪兽也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lmtg)
	e1:SetOperation(s.lmop)
	c:RegisterEffect(e1)
end
-- 过滤条件：对方场上表侧表示且在这张卡所连接区的怪兽
function s.filter(c,lg)
	return c:IsFaceup() and lg:IsContains(c)
end
-- 效果①的Target函数：检查并选择对方场上所连接区的1只表侧表示怪兽作为对象
function s.lmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,lg) end
	-- 判断是否存在可以作为对象的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,lg) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择并锁定1只对方场上所连接区的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,lg)
end
-- 效果①的Operation函数：给作为对象的怪兽注册‘可作为连接素材’的效果，并用Flag标记自身以作校验
function s.lmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个回合，自己用自己场上的这张卡为素材把连接5怪兽连接召唤的场合，作为对象的对方怪兽也能作为连接素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabelObject(c)
		e1:SetLabel(fid)
		e1:SetCondition(s.mcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.matval)
		tc:RegisterEffect(e1)
	end
end
-- 连接素材效果的启用条件：该怪兽必须在对方场上
function s.mcon(e)
	local tp=e:GetOwner():GetControler()
	return e:GetHandler():IsControler(1-tp)
end
-- 连接素材效果的数值/判定函数：限制必须是连接5怪兽的连接召唤，且自身必须作为素材
function s.matval(e,lc,mg,c,tp)
	local ct=e:GetLabelObject()
	local fid=e:GetLabel()
	if not lc:IsLink(5) or ct:GetFlagEffectLabel(id)~=fid then return false,nil end
	return true,not mg or mg:IsContains(ct)
end
