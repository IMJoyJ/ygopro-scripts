--冥界の麗人イゾルデ
-- 效果：
-- 这张卡不用这张卡的①的方法不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「冥界骑士 崔斯坦」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己场上最多2只不死族怪兽为对象，宣言5～8的任意等级才能发动。那些怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c22657402.initial_effect(c)
	-- 这张卡不用这张卡的①的方法不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上有「冥界骑士 崔斯坦」存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c22657402.spcon)
	c:RegisterEffect(e2)
	-- ②：以自己场上最多2只不死族怪兽为对象，宣言5～8的任意等级才能发动。这个卡名的②的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,22657402)
	e3:SetTarget(c22657402.target)
	e3:SetOperation(c22657402.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为表侧表示的「冥界骑士 崔斯坦」（卡号96163807）
function c22657402.spfilter(c)
	return c:IsFaceup() and c:IsCode(96163807)
end
-- 特殊召唤条件：自己主要怪兽区有空位且自己场上存在「冥界骑士 崔斯坦」时，这张卡可以从手卡特殊召唤
function c22657402.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有可用空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「冥界骑士 崔斯坦」
		and Duel.IsExistingMatchingCard(c22657402.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：检查卡片是否为表侧表示、持有等级的不死族怪兽
function c22657402.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsRace(RACE_ZOMBIE)
end
-- ②效果的对象处理：选择自己场上1～2只不死族怪兽为对象，并宣言5～8的任意等级
function c22657402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c22657402.filter(chkc) end
	-- 效果发动条件检查：自己场上是否存在至少1只可作为对象的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c22657402.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 以自己场上最多2只不死族怪兽为对象
	local g=Duel.SelectTarget(tp,c22657402.filter,tp,LOCATION_MZONE,0,1,2,nil)
	local lv1=g:GetFirst():GetLevel()
	local lv2=0
	local tc2=g:GetNext()
	if tc2 then lv2=tc2:GetLevel() end
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 宣言5～8的任意等级（排除对象怪兽现有的等级）
	local lv=Duel.AnnounceLevel(tp,5,8,lv1,lv2)
	e:SetLabel(lv)
end
-- 过滤函数：检查对象怪兽是否仍为表侧表示且与本效果关联
function c22657402.lvfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- ②效果的处理：将对象怪兽的等级变成宣言的等级直到回合结束，之后这个回合自己不是不死族怪兽不能特殊召唤
function c22657402.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果的对象卡片组，并筛选出仍为表侧表示且与本效果关联的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c22657402.lvfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c22657402.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把特殊召唤限制效果注册为对发动玩家生效的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制判定：特殊召唤的怪兽不是不死族的场合禁止特殊召唤
function c22657402.splimit(e,c)
	return c:GetRace()~=RACE_ZOMBIE
end
