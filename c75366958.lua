--ダイナレスラー・コエロフィシラット
-- 效果：
-- 这个卡名的①的方法的特殊召唤在决斗中只能有1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。把这个方法特殊召唤的这张卡作为连接召唤的素材的场合，不是「恐龙摔跤手」怪兽的连接召唤不能使用。
function c75366958.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤在决斗中只能有1次。①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,75366958+EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c75366958.spcon)
	e1:SetOperation(c75366958.spop)
	c:RegisterEffect(e1)
end
-- 判断自身特殊召唤的条件是否满足（自己场上没有怪兽且有空余怪兽区域）
function c75366958.spcon(e,c)
	if c==nil then return true end
	-- 确认自己场上的怪兽数量为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 确认自己场上有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 在特殊召唤成功时，为自身注册作为连接素材时的限制效果
function c75366958.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 把这个方法特殊召唤的这张卡作为连接召唤的素材的场合，不是「恐龙摔跤手」怪兽的连接召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c75366958.linklimit)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 判定连接召唤的怪兽是否不属于「恐龙摔跤手」系列
function c75366958.linklimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x11a)
end
