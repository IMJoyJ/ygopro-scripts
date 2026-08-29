--EMレビュー・ダンサー
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「娱乐伙伴」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c36527535.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c36527535.sprcon)
	c:RegisterEffect(e1)
	-- ②：「娱乐伙伴」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c36527535.dtcon)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：自己主要怪兽区无怪兽、对方主要怪兽区有怪兽且自己怪兽区有空格
function c36527535.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区没有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方主要怪兽区有怪兽存在
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己主要怪兽区是否有可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 双祭品效果适用条件：「娱乐伙伴」怪兽上级召唤且自身表侧表示或同控制者
function c36527535.dtcon(e,c)
	local ec=e:GetHandler()
	return c:IsSetCard(0x9f) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
