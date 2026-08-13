--エレキーウィ
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上存在的名字带有「电气」的怪兽攻击的场合，攻击怪兽不会被战斗破坏。
function c24996659.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上存在的名字带有「电气」的怪兽攻击的场合，攻击怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c24996659.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 定义该永续效果对怪兽的适用判定函数：仅当被判定怪兽是名字带有「电气」的怪兽，且为当前进行攻击的怪兽时，该效果才适用。
function c24996659.indtg(e,c)
	-- 检查被判定怪兽是否满足两个条件：卡名属于「电气」字段，且该怪兽正是当前攻击宣言的怪兽；两者同时成立时返回真，表示它不会被战斗破坏。
	return c:IsSetCard(0xe) and c==Duel.GetAttacker()
end
