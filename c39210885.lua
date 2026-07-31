--天魔の聲選器－『ヴァルモニカ』
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「异响鸣」怪兽加入手卡。
-- ②：自己的灵摆区域的卡有响鸣指示物被放置，那卡的响鸣指示物变成3个的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能攻击宣言。
local s,id,o=GetID()
-- 创建卡牌效果，注册两个效果：①检索怪兽加入手牌；②灵摆指示物变为3时可夺取对方怪兽控制权并禁止攻击宣言
function s.initial_effect(c)
	-- 效果①：作为这张卡的发动时的效果处理，可以从卡组把1只「异响鸣」怪兽加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：自己的灵摆区域的卡有响鸣指示物被放置，那卡的响鸣指示物变成3个的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.concon)
	e2:SetTarget(s.contg)
	e2:SetOperation(s.conop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 过滤函数：筛选「异响鸣」怪兽（怪兽类型且可加入手牌）
function s.filter(c)
	return c:IsSetCard(0x1a3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的处理函数：从卡组检索符合条件的「异响鸣」怪兽并加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「异响鸣」怪兽组
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的怪兽且玩家选择发动效果
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把1只「异响鸣」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 触发条件函数：判断是否为自己的回合
function s.concon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 设置目标选择函数：选择对方场上的可改变控制权的怪兽
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsControlerCanBeChanged() end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上一个可改变控制权的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，记录将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果②的处理函数：夺取目标怪兽控制权并禁止其攻击宣言
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且成功获得控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)>0 then
		-- 为获得控制权的怪兽添加不能攻击宣言的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
