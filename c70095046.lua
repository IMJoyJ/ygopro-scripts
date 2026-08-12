--クリアー・ヴィシャス・ナイト
-- 效果：
-- 这张卡可以把有「清透世界」的卡名记述的1只怪兽解放作上级召唤。
-- ①：这张卡的攻击力上升对方场上的怪兽的最高原本攻击力数值。
-- ②：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
-- ③：只要上级召唤的这张卡在怪兽区域存在，对方不能把持有比这张卡低的攻击力的场上的特殊召唤的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果，包括替代上级召唤规则、攻击力上升、不受「清透世界」影响、限制对方怪兽效果发动。
function s.initial_effect(c)
	-- 将「清透世界」的卡片密码（33900648）注册到此卡的关联卡片列表中。
	aux.AddCodeList(c,33900648)
	-- 这张卡可以把有「清透世界」的卡名记述的1只怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升对方场上的怪兽的最高原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE,EFFECT_FLAG2_WICKED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetCode(97811903)
	c:RegisterEffect(e4)
	-- ③：只要上级召唤的这张卡在怪兽区域存在，对方不能把持有比这张卡低的攻击力的场上的特殊召唤的怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(s.thcon)
	e5:SetValue(s.limval)
	c:RegisterEffect(e5)
end
-- 过滤函数：筛选场上记述了「清透世界」卡名的怪兽。
function s.otfilter(c)
	-- 判断卡片文本中是否记述了「清透世界」的卡名。
	return aux.IsCodeListed(c,33900648)
end
-- 替代上级召唤的条件函数：判断是否满足进行替代上级召唤的条件。
function s.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上所有记述了「清透世界」卡名的怪兽。
	local mg=Duel.GetMatchingGroup(s.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判断自身是否为7星以上怪兽、最少解放数量是否不大于1，且场上是否存在1只满足条件的解放怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 替代上级召唤的执行函数：选择并解放1只记述了「清透世界」卡名的怪兽进行上级召唤。
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有记述了「清透世界」卡名的怪兽作为解放候选。
	local mg=Duel.GetMatchingGroup(s.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 让玩家选择1只记述了「清透世界」卡名的怪兽作为上级召唤的解放祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽，作为上级召唤的素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 攻击力上升值的计算函数：获取对方场上表侧表示怪兽的最高原本攻击力数值。
function s.adval(e,c)
	-- 获取对方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetOwnerPlayer(),0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetBaseAttack)
		return val
	end
end
-- 限制效果发动的条件函数：此卡必须是通过上级召唤出场。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 限制效果发动的过滤函数：限制对方场上特殊召唤的、且攻击力低于此卡的怪兽发动的怪兽效果。
function s.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		and rc:IsSummonType(SUMMON_TYPE_SPECIAL)
		and rc:GetAttack()<e:GetHandler():GetAttack()
end
