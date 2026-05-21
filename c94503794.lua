--漆梏の喰獣 ケルゼブス
-- 效果：
-- 7星怪兽×2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×700。
-- ②：通常·速攻魔法卡发动时才能发动（同一连锁上最多1次）。场上的那张卡作为表侧表示的这张卡的超量素材，这张卡不受那个发动的效果影响。
-- ③：自己·对方的结束阶段才能发动。这张卡作为超量素材中的1张魔法卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果注册函数，定义XYZ召唤手续、攻击力上升、吸收魔法卡为素材并获得免疫、以及结束阶段盖放素材中魔法卡的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤手续：7星怪兽2只以上
	aux.AddXyzProcedure(c,nil,7,2,nil,nil,99)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：通常·速攻魔法卡发动时才能发动（同一连锁上最多1次）。场上的那张卡作为表侧表示的这张卡的超量素材，这张卡不受那个发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"获取超量素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。这张卡作为超量素材中的1张魔法卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 计算并返回攻击力上升值，数值为这张卡的超量素材数量乘以700
function s.atkval(e,c)
	return c:GetOverlayCount()*700
end
-- 检查发动的效果是否为通常魔法或速攻魔法的发动，作为效果②的发动条件
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (re:IsActiveType(TYPE_QUICKPLAY) or re:GetHandler():GetType()==TYPE_SPELL)
end
-- 效果②的靶向处理：确认发动的魔法卡可以作为超量素材，且自身是XYZ怪兽，并建立卡片与效果的联系
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() and e:GetHandler():IsType(TYPE_XYZ) end
	re:GetHandler():CreateEffectRelation(e)
end
-- 效果②的操作处理：将发动的魔法卡作为超量素材重叠，并使自身不受该发动效果的影响
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain()
		and tc:IsRelateToChain() and tc:IsCanOverlay()
		and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		-- 将发动的魔法卡作为超量素材重叠到这张卡下
		Duel.Overlay(c,tc)
		-- 这张卡不受那个发动的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		e1:SetValue(s.efilter(re))
		c:RegisterEffect(e1)
	end
end
-- 免疫效果的过滤器，用于判定是否为该次发动的魔法卡效果
function s.efilter(re)
	return	function(e,te)
				return te==re and te:IsActivated()
			end
end
-- 过滤出可以盖放在自己场上的魔法卡（需满足是魔法卡、可盖放，且魔陷区有空位或是场地魔法）
function s.setfilter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsSSetable()
		-- 检查魔陷区是否有空位，或者该卡是否为场地魔法卡
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsType(TYPE_FIELD))
end
-- 效果③的靶向处理：确认超量素材中存在可盖放的魔法卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetOverlayGroup()
	if chk==0 then return g:IsExists(s.setfilter,1,nil,tp) end
end
-- 效果③的操作处理：从超量素材中选择1张魔法卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local g=c:GetOverlayGroup()
		-- 向玩家发送提示信息，要求选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:FilterSelect(tp,s.setfilter,1,1,nil,tp)
		if sg:GetCount()>0 then
			-- 将选中的魔法卡在自己场上盖放
			Duel.SSet(tp,sg:GetFirst())
		end
	end
end
