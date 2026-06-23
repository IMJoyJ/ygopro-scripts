--仮面魔獣デス・ガーディウス
-- 效果：
-- 这张卡不能通常召唤。把包含「假面咒术师 诅咒之喉」「梅尔基多四面兽」之内任意种的自己场上2只怪兽解放的场合可以特殊召唤。
-- ①：这张卡从场上送去墓地的场合，以对方场上1只表侧表示怪兽为对象发动。从卡组把1张「遗言之假面」当作装备卡使用给作为对象的怪兽装备。
function c48948935.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个特殊召唤规则效果，用于限制此卡只能通过解放满足条件的怪兽来特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c48948935.spcon)
	e1:SetTarget(c48948935.sptg)
	e1:SetOperation(c48948935.spop)
	c:RegisterEffect(e1)
	-- 创建一个诱发效果，当此卡从场上送去墓地时发动，将「遗言之假面」装备给对方场上一只表侧表示怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48948935,0))  --"装备"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c48948935.eqcon)
	e2:SetTarget(c48948935.eqtg)
	e2:SetOperation(c48948935.eqop)
	c:RegisterEffect(e2)
end
-- 检查所选怪兽组中是否包含「假面咒术师 诅咒之喉」或「梅尔基多四面兽」，并验证释放后主怪兽区是否有足够空位
function c48948935.fselect(g,tp)
	-- 返回值为真表示所选怪兽数量为2且满足条件（包含指定卡名且可释放）
	return g:IsExists(Card.IsCode,1,nil,13676474,86569121) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 检查是否满足特殊召唤条件：获取可解放的怪兽组并验证其子集是否满足fselect函数要求
function c48948935.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家当前可解放的怪兽组，不包括手牌
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return rg:CheckSubGroup(c48948935.fselect,2,2,tp)
end
-- 选择满足条件的2只怪兽进行解放，并将该组保存到效果标签中
function c48948935.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家当前可解放的怪兽组，不包括手牌
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c48948935.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的解放操作，将之前选择的怪兽组进行实际解放
function c48948935.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽组从场上解放，原因设为特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断此卡是否是从场上送去墓地（而非其他方式如返回手牌）
function c48948935.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择对方场上一只表侧表示的怪兽作为装备对象
function c48948935.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择对方场上一只表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择一只表侧表示的怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 过滤函数，用于筛选卡组中「遗言之假面」（卡号22610082）且未被禁止的卡片
function c48948935.filter(c)
	return c:IsCode(22610082) and not c:IsForbidden()
end
-- 执行装备操作：从卡组选择一张「遗言之假面」并装备给目标怪兽，同时设置装备限制和控制权效果
function c48948935.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家魔法陷阱区域是否还有空位，若无则不继续执行装备
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要装备的「遗言之假面」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组中选择一张「遗言之假面」作为装备卡
		local g=Duel.SelectMatchingCard(tp,c48948935.filter,tp,LOCATION_DECK,0,1,1,nil)
		local eqc=g:GetFirst()
		-- 尝试将选定的装备卡装备给目标怪兽，若失败则不继续执行
		if not eqc or not Duel.Equip(tp,eqc,tc) then return end
		-- 创建一个装备限制效果，确保该装备卡只能被指定的怪兽装备
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c48948935.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1)
		-- 创建一个装备效果，使装备卡获得控制权
		local e2=Effect.CreateEffect(eqc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		eqc:RegisterEffect(e2)
	end
end
-- 返回值为真表示当前装备卡只能被指定的怪兽装备
function c48948935.eqlimit(e,c)
	return e:GetLabelObject()==c
end
