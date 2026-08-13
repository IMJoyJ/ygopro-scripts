--ギミック・パペット－マグネ・ドール
-- 效果：
-- ①：对方场上有怪兽存在，自己场上的怪兽只有「机关傀儡」怪兽的场合，这张卡可以从手卡特殊召唤。
function c39806198.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上的怪兽只有「机关傀儡」怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c39806198.spcon)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则条件判定：在系统检查特殊召唤是否可行时，先允许空c的查询，然后依次确认自己主怪兽区有空位、对方场上有怪兽、自己场上有怪兽且全部是表侧表示的「机关傀儡」怪兽。
function c39806198.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有可用的空位，保证有特殊召唤的格子。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上存在怪兽（自己主要怪兽区怪兽数量大于0）。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查对方场上存在怪兽（对方主要怪兽区怪兽数量大于0）。
		and	Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上不存在“里侧表示或不是「机关傀儡」”的怪兽，即自己场上的怪兽全部为表侧表示的「机关傀儡」怪兽。
		and not Duel.IsExistingMatchingCard(c39806198.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：若怪兽是里侧表示或不属于「机关傀儡」（卡名含有0x1083字段），则视为不符合“自己场上的怪兽只有「机关傀儡」怪兽”的要求。
function c39806198.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x1083)
end
