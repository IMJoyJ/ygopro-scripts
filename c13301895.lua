--失楽園
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，自己的怪兽区域的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：自己的怪兽区域有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」的其中任意种存在的场合才能发动。自己从卡组抽2张。
function c13301895.initial_effect(c)
	-- 将这张卡效果文本中提到的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」登记到卡片代码列表，用于关联检索与效果处理。
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己的怪兽区域的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c13301895.immtg)
	-- 设置该免疫效果的值函数为aux.tgoval，用于判定“不会成为对方的效果的对象”的场合。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置该免疫效果的值函数为aux.indoval，用于判定“不会被对方的效果破坏”的场合。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的怪兽区域有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」的其中任意种存在的场合才能发动。自己从卡组抽2张。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,13301895)
	e4:SetCondition(c13301895.drcon)
	e4:SetTarget(c13301895.drtg)
	e4:SetOperation(c13301895.drop)
	c:RegisterEffect(e4)
end
-- 免疫对象筛选：判断候选怪兽是否为「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」之一，是则享受①的“不会成为对象/不会被效果破坏”保护。
function c13301895.immtg(e,c)
	return c:IsCode(6007213,32491822,69890967,43378048)
end
-- 抽卡效果的条件筛选：怪兽必须表侧表示且为上述四张幻魔卡之一。
function c13301895.drcfilter(c)
	return c:IsFaceup() and c:IsCode(6007213,32491822,69890967,43378048)
end
-- ②的发动条件：检查自己怪兽区域是否存在满足条件的幻魔怪兽（1只以上）。
function c13301895.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件判定：在自己怪兽区域检索是否存在至少1张满足drcfilter筛选条件的怪兽卡。
	return Duel.IsExistingMatchingCard(c13301895.drcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动时目标设定：将抽卡对象玩家设为自己，抽卡数设为2，并登记操作信息，供后续效果处理使用。
function c13301895.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：只有自己可以抽2张卡时才允许发动该效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 把当前连锁效果的对象玩家设置为tp（即效果发动者，抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁效果的对象参数设置为2，表示抽卡张数为2。
	Duel.SetTargetParam(2)
	-- 登记“抽卡”类操作信息：目标卡为nil（无卡对象），目标玩家为tp，参数为2，用于时点/连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：读取连锁中保存的目标玩家和抽卡张数，然后执行抽卡。
function c13301895.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁保存的对象玩家和对象参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因让玩家p抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
