--超重武者ビッグワラ－G
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
function c36523152.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c36523152.spcon)
	e1:SetOperation(c36523152.spop)
	c:RegisterEffect(e1)
	-- ②：机械族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c36523152.condition)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件判定：自身主要怪兽区有空格且自己墓地没有魔法·陷阱卡存在
function c36523152.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤成功时的操作：对自身施加特殊召唤限制
function c36523152.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c36523152.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将特殊召唤限制效果注册给自身玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤：非「超重武者」怪兽不能特殊召唤
function c36523152.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- 双祭品效果适用条件：机械族怪兽上级召唤且自身表侧表示或同控制者
function c36523152.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_MACHINE) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
