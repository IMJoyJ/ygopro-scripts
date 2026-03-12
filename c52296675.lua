--アンカモフライト
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己的额外卡组的卡不存在的场合或者只有「迷彩光书签」的场合才能发动。这张卡破坏。那之后，自己从卡组抽1张。
-- 【怪兽效果】
-- 这张卡不能通常召唤。这张卡在额外卡组表侧表示存在，「迷彩光书签」以外的卡不在自己的额外卡组存在的场合才能特殊召唤。这个方法的「迷彩光书签」的特殊召唤1回合只能有1次。
-- ①：怪兽区域的表侧表示的这张卡从场上离开的场合除外。
function c52296675.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己的额外卡组的卡不存在的场合或者只有「迷彩光书签」的场合才能发动。这张卡破坏。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52296675,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,52296675)
	e1:SetCondition(c52296675.drcon)
	e1:SetTarget(c52296675.drtg)
	e1:SetOperation(c52296675.drop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 这张卡在额外卡组表侧表示存在，「迷彩光书签」以外的卡不在自己的额外卡组存在的场合才能特殊召唤。这个方法的「迷彩光书签」的特殊召唤1回合只能有1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,52296676+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(c52296675.hspcon)
	c:RegisterEffect(e3)
	-- 为卡片注册一个“从场上离开时改为除外”的效果，使该卡在离场时强制被除外
	aux.AddBanishRedirect(c,c52296675.recon)
end
-- 过滤函数，用于判断额外卡组中是否存在「迷彩光书签」且处于表侧表示状态
function c52296675.drfilter(c)
	return c:IsFaceup() and c:IsCode(52296675)
end
-- 条件函数，判断是否满足发动灵摆效果的条件：额外卡组没有卡或只有「迷彩光书签」
function c52296675.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家额外卡组中的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	-- 判断额外卡组中卡的数量为0或者等于「迷彩光书签」的数量
	return ct==0 or ct==Duel.GetMatchingGroupCount(c52296675.drfilter,tp,LOCATION_EXTRA,0,nil)
end
-- 设置连锁操作信息，指定破坏和抽卡的效果目标
function c52296675.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行抽卡效果
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息中的破坏类别，目标为当前卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息中的抽卡类别，目标为发动者本人，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行灵摆效果的处理函数，先破坏自身再抽一张卡
function c52296675.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否与当前效果相关联并且成功被破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 中断当前连锁处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 让发动者从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 特殊召唤条件函数，判断是否满足「迷彩光书签」的特殊召唤条件
function c52296675.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家额外卡组中的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	-- 判断额外卡组中卡的数量等于「迷彩光书签」数量且场上存在足够的召唤空位
	return ct==Duel.GetMatchingGroupCount(c52296675.drfilter,tp,LOCATION_EXTRA,0,nil) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 离场重定向效果的适用条件函数，当卡片在主要怪兽区且表侧表示时适用
function c52296675.recon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
