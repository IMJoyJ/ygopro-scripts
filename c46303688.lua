--ルーレットボマー
-- 效果：
-- 在自己的每回合的主要阶段可以掷2次骰子，在掷出的点数中选择1个，破坏场上1只表侧表示的与此点数相同等级的怪兽。
function c46303688.initial_effect(c)
	-- 在自己的每回合的主要阶段可以掷2次骰子，在掷出的点数中选择1个，破坏场上1只表侧表示的与此点数相同等级的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46303688,0))  --"掷骰子"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c46303688.target)
	e1:SetOperation(c46303688.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：无发动条件限制，无条件允许发动；并登记本连锁将进行2次掷骰子的操作信息。
function c46303688.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记当前连锁的操作信息：效果类别为掷骰子（CATEGORY_DICE），目标玩家为tp，预计掷2次骰子，为后续相关判定提供依据。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 过滤条件：候选怪兽必须为表侧表示，且其等级等于参数lv（掷出的点数值）。
function c46303688.dfilter(c,lv)
	return c:IsFaceup() and c:IsLevel(lv)
end
-- 效果处理：投掷2次骰子；若点数不同，由玩家从2个点数中选择1个作为最终点数；然后在场上选择1只表侧表示且等级等于该点数的怪兽破坏。
function c46303688.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家tp投掷2次骰子，得到两个点数d1和d2（各为1~6）。
	local d1,d2=Duel.TossDice(tp,2)
	local sel=d1
	if d1>d2 then d1,d2=d2,d1 end
	if d1~=d2 then
		-- 若两个点数不同，让玩家tp在两个点数中宣言选择1个，作为最终用于破坏等级判定的点数sel。
		sel=Duel.AnnounceNumber(tp,d1,d2)
	end
	-- 向玩家tp发送选择卡片的提示消息，提示内容为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 在双方怪兽区域选择1只表侧表示且等级等于sel的怪兽作为破坏对象；若没有符合条件的怪兽则选择失败。
	local dg=Duel.SelectMatchingCard(tp,c46303688.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,sel)
	if dg:GetCount()>0 then
		-- 将选择出的怪兽以效果破坏（送入墓地）。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
