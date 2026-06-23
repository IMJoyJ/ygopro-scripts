--タイガードラゴン
-- 效果：
-- 把龙族怪兽解放对这张卡的上级召唤成功时，可以把对方的魔法与陷阱卡区域盖放的最多2张卡破坏。
function c10097168.initial_effect(c)
	-- 把龙族怪兽解放对这张卡的上级召唤成功时，可以把对方的魔法与陷阱卡区域盖放的最多2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10097168,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c10097168.condition)
	e1:SetTarget(c10097168.target)
	e1:SetOperation(c10097168.operation)
	c:RegisterEffect(e1)
	-- 把龙族怪兽解放对这张卡的上级召唤成功时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c10097168.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查召唤素材（解放的怪兽）中是否存在龙族怪兽并设置标志
function c10097168.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsRace,1,nil,RACE_DRAGON) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 效果发动的条件判断：上级召唤成功且解放的怪兽中存在龙族怪兽
function c10097168.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 过滤条件：对方魔法与陷阱卡区域盖放的卡（排除场地区）
function c10097168.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 效果发动的准备：以对方魔法与陷阱卡区域盖放的卡（最多2张）为对象
function c10097168.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) end
	-- 检查对方魔法与陷阱卡区域是否存在可以作为对象的盖放卡
	if chk==0 then return Duel.IsExistingTarget(c10097168.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方魔法与陷阱卡区域盖放的最多2张卡作为对象并设置
	local g=Duel.SelectTarget(tp,c10097168.filter,tp,0,LOCATION_SZONE,1,2,nil)
	-- 设置破坏这些卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤条件：仍与效果有联系且处于里侧表示的卡
function c10097168.dfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFacedown()
end
-- 效果处理：破坏作为对象的卡
function c10097168.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(c10097168.dfilter,nil,e)
	if g:GetCount()>0 then
		-- 破坏这些卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
